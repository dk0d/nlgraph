#!/bin/bash

##### ARGUMENTS ######
ENV_NAME=${1-nlgraph}
PYTHON_VERSION=${2-3.9}
PYTORCH_VERSION=${3-1.12}
CUDA_VERSION=${4-}
######################

if [[ -z "$CUDA_VERSION" ]]
then
  if ! command -v nvidia-smi &> /dev/null
  then
    CUDA_VERSION=""
  else
    CUDA_VERSION="$(nvidia-smi | egrep -o 'CUDA Version:\s([0-9.])+' | egrep -o '[0-9.]+')"
    echo "FOUND CUDA Version: $CUDA_VERSION"
  fi
fi

if [[ "$PYTORCH_VERSION" == "latest" ]]
then
  TORCH_STRING="pytorch"
else
  TORCH_STRING="pytorch=$PYTORCH_VERSION"
fi


echo "
creating env    :   $ENV_NAME
python version  :   $PYTHON_VERSION
pytorch version :   $PYTORCH_VERSION ($TORCH_STRING)
cuda version    :   $CUDA_VERSION
"

find_in_conda_env(){
    conda env list | grep "${@}" >/dev/null 2>/dev/null
}

if ! command -v conda &> /dev/null
then
    echo "Sourcing conda..."
    source /usr/local/anaconda3/settings
fi

eval "$(conda shell.bash hook)"

if find_in_conda_env "$ENV_NAME" ; then
  echo "Removing existing $ENV_NAME environment..."
  conda env remove --name $ENV_NAME
  echo "Done."
  echo "Re-installing fresh $ENV_NAME environment..."
else
  echo "Installing $ENV_NAME environment..."
fi

conda create -n $ENV_NAME python=$PYTHON_VERSION -y
source activate $ENV_NAME

#if [[ "$OSTYPE" == "linux-gnu"* ]]; then # ...
#elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
#elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
#elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
#elif [[ "$OSTYPE" == "freebsd"* ]]; then # ...
#else  # Unknown.
#fi

if [[ "$CUDA_VERSION" != "" ]]; then
  conda install $TORCH_STRING torchvision torchaudio cudatoolkit=$CUDA_VERSION -c pytorch -y
else
  conda install $TORCH_STRING torchvision torchaudio -c pytorch -y
fi

# Pytorch-geometric
conda install pyg -c pyg -y
#if [[ $PYTORCH_VERSION == "latest" ]]; then
#  GEO_URL=https://data.pyg.org/whl/torch-1.12
#else
#  GEO_URL=https://data.pyg.org/whl/torch-$PYTORCH_VERSION
#fi
#if [[ "$CUDA_VERSION" != "" ]]; then
#  CV="${$CUDA_VERSION//.}"
#  GEO_URL="$GEO_URL+cu$CV.html"
#else
#  GEO_URL="$GEO_URL+cpu.html"
#fi
#pip install torch-scatter torch-sparse torch-cluster torch-spline-conv torch-geometric -f $GEO_URL

# Pytorch-lightning
pip install pytorch-lightning

# PyQT6
pip install pyqtgraph

pip install category_encoders

# Other packages
conda install seaborn networkx jsonpickle ipython pandas tqdm pytest matplotlib scikit-image scipy scikit-learn scikit-learn-intelex pyyaml -y

pip install -e .

echo ""
echo "GOOD TO GO!"
echo "Activate the $ENV_NAME environment by entering 'conda activate $ENV_NAME'

