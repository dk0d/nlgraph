from typing import NamedTuple

import numpy as np
from sklearn.model_selection import train_test_split


class TestSplitMask(NamedTuple):
    train: np.ndarray
    val: np.ndarray
    test: np.ndarray


def idxToMask(idxs: np.ndarray, maskSize: np.ndarray) -> np.ndarray:
    mask = np.zeros(maskSize)
    mask[idxs] = 1
    return np.array(mask, dtype=np.bool)


def trainValTestSplit(labels, trainSize=0.7, testSize=0.5) -> TestSplitMask:
    """

    :param labels: classification/regression labels for data, assumes num rows == # samples
    :param trainSize: percent of total labels for training (0.7: 100 -> 70 train, 30 val/test)
    :param testSize: percent of val/test for test split (0.5: 30 -> 15 val, 15 test)
    :return:
    """
    indices = np.arange(labels.shape[0])
    idx_tr, idx_te, y_tr, y_te = train_test_split(
        indices, labels, train_size=trainSize, stratify=labels)
    idx_va, idx_te, y_va, y_te = train_test_split(
        idx_te, y_te, train_size=testSize, stratify=y_te)

    # Train/valid/test masks
    mask_train = idxToMask(idx_tr, labels.shape[0])
    mask_val = idxToMask(idx_va, labels.shape[0])
    mask_test = idxToMask(idx_te, labels.shape[0])

    return TestSplitMask(mask_train, mask_val, mask_test)
