import pandas as pd
import numpy as np
import math
import pickle
from collections import defaultdict
import os
from datetime import datetime
import argparse
from pathlib import Path
import shutil
import json
import re
import copy
import functools
from operator import add
import shap
import matplotlib.pyplot as plt
from hyperopt import STATUS_OK, Trials, fmin, hp, tpe
from hyperopt.pyll import scope
from hyperopt.early_stop import no_progress_loss
from xgboost import XGBRegressor
from sklearn.linear_model import Lasso
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.impute import KNNImputer
from sklearn.compose import TransformedTargetRegressor
from sklearn.base import BaseEstimator
from sklearn.base import RegressorMixin
from sklearn.model_selection import (
    cross_val_score,
    GridSearchCV,
    GroupShuffleSplit,
    StratifiedGroupKFold,
    GroupKFold,
)
from sklearn.metrics import mean_squared_error
import sklearn.utils as sk_utils
from pycm import ConfusionMatrix

# Create log file to store main messages
log_dir_name = "./log/"
log_dir_name = Path(log_dir_name)
if log_dir_name.exists() and log_dir_name.is_dir():
    shutil.rmtree(log_dir_name)
os.makedirs(log_dir_name)
log_dir_name = str(log_dir_name) + "/model.log"


parser = argparse.ArgumentParser()
parser.add_argument(
    "-p", "--path", type=str, required=True, help="Path to Config JSON file"
)
parser.add_argument(
    "-t",
    "--train",
    action="store_true",
    help="Whether models need to be trained. Use flag --train if models are needed to be trained",
)

args = parser.parse_args()

directory_name = args.path

if os.path.isfile(directory_name) and directory_name.endswith(".json"):
    with open(directory_name, "r") as f:
        config = json.load(f)

    with open(log_dir_name, "a") as logfile:
        logfile.write(f"{datetime.now()}: Config file passed successfully\n")
else:
    with open(log_dir_name, "a") as logfile:
        logfile.write(
            f'{datetime.now()}: Config file failed: "Please indicate full path to Config JSON file \n Example: python main.py --path path/config.json"\n'
        )

    raise TypeError(
        "Please indicate full path to Config JSON file \n Example: python main.py --path path/config.json"
    )


def get_directory(directory_name):
    """
    The function gets the directory
    from file path or directory.

    Args:
        directory_name (str): directory name.

    Returns:
        str: directory.
    """
    directory_name = list(directory_name)
    n = len(directory_name)
    for idx in range(n - 1, -1, -1):
        if directory_name[idx] == "/":
            break

    return "".join(directory_name[: idx + 1])


def get_train_features(model_rasi, model_sglt2i, model_mcra, new_data_csv):
    """
    The function gets model parameters to be trained
    based on new train data.

    Args:
        model_rasi (str): path to the model rasi.
        model_sglt2i (str): path to the model sglt2i.
        model_mcra (str): path to the model mcra.
        new_data_csv (str): path to new train data.

    Returns:
        dict: model parameters for RASI, SGLT2i, MCRA.
    """
    if os.path.isfile(new_data_csv) and new_data_csv.endswith(".csv"):
        pass
    else:
        with open(log_dir_name, "a") as logfile:
            logfile.write(
                f"{datetime.now()}: New data to train failed: New data must be full path to comma-separated csv file in string format\n"
            )
        raise TypeError(
            "New data must be full path to comma-separated csv file in string format"
        )

    new_train_data = pd.read_csv(new_data_csv, sep=",")
    seqtype = set(new_train_data.SEQTYPE.values)
    params = defaultdict(list)

    if "1rs" in seqtype or "2s" in seqtype:
        params["sglt2i"].append("1rs")
        params["sglt2i"].append(["['0r', '1rg', '2g', '2m']", False, False, 0.3])
        with open(model_sglt2i, "rb") as f:
            _, features, _ = pickle.load(f)
        params["sglt2i"].append(features)

    if "1rm" in seqtype or "2m" in seqtype:
        params["mcra"].append("1rm")
        params["mcra"].append(["['0r', '1rs', '2s', '1rg', '2g']", False, False, 0.3])
        with open(model_mcra, "rb") as f:
            _, features, _ = pickle.load(f)
        params["mcra"].append(features)

    if "0r" in seqtype:
        params["rasi"].append("0r")
        params["rasi"].append(["['1rs', '1rg', '2g', '2m']", True, False, None])
        with open(model_rasi, "rb") as f:
            _, features, _ = pickle.load(f)
        params["rasi"].append(features)

    if len(params) == 0:
        with open(log_dir_name, "a") as logfile:
            logfile.write(
                f"{datetime.now()}: No valid SEQTYPE found in new training data. SEQTYPE must be in one or more of the [0r, 1rs, 2s, 1rm, 2m]\n"
            )
        raise TypeError(
            "No valid SEQTYPE found in new training data. SEQTYPE must be in one or more of the [0r, 1rs, 2s, 1rm, 2m]"
        )

    with open(log_dir_name, "a") as logfile:
        logfile.write(f"{datetime.now()}: New training data passed successfully\n")

    return params


def TC_convert(x, thresh=-0.1):
    """
    The function computes controlled and uncontrolled
    based on threshold and DEGFR.

    Args:
        x (list): array of [EGFR, EGFR_next]
        thresh (float, optional): defaults to -0.1.

    Returns:
        str: controlled or uncontrolled.
    """
    if math.isnan(x[0]) or math.isnan(x[1]):
        return np.nan
    elif (x[1] - x[0]) / x[0] >= thresh:
        return "controlled"
    else:
        return "uncontrolled"
    

def check_variables_inclusion(dataset, model_features):
    """
    Checks if all the features required by a machine learning model are present in the dataset.

    Parameters:
        dataset (pd.DataFrame): The input dataset to check against.
        model_features (List): A list of feature names required by the model.

    Raises:
        Exception: If any feature is missing in the dataset, an exception is raised with an appropriate error message.
                   The error message is also logged to a file for debugging purposes.
    """
    dataset_features = set(dataset.columns.values)
    missing_features = model_features - dataset_features

    if missing_features:
        error_message = f"{datetime.now()}: Model validation failed: variables {missing_features} not in the dataset..."
        with open(log_dir_name, "a") as logfile:
            logfile.write(error_message)
        raise Exception(error_message)


def update_shap(shap_values, ft="EGFR", shap_ft=None):
    """
    The function update the shap values based on selected features
    and whether EGFR included or not.

    Args:
        shap_values (numpy.ndarray): computed shap values.
        ft (str, optional): defaults to "EGFR".
        shap_ft (list, optional): shap features. Defaults to None.

    Returns:
        numpy.ndarray: updated shap values.
    """
    new_shap_values = copy.deepcopy(shap_values)
    idx = np.argmax(abs(new_shap_values.values))
    EGFR_idx = shap_ft.index(ft)
    new_shap_values.values[idx] = (
        new_shap_values.values[idx] + new_shap_values.values[EGFR_idx]
    )
    new_shap_values.values = new_shap_values.values[:EGFR_idx]
    new_shap_values.data = new_shap_values.data[:EGFR_idx]
    return new_shap_values


class CustomCrossValidation:
    """
    CrossValidation with groupings and bootstrapping
    """

    def __init__(
        self,
        seqtype,
        groups,
        n_splits=10,
        stratify=None,
        shuffle=True,
        target=None,
        includeInTrain=None,
        test_size=None,
        random_state=None,
    ):
        self.n_splits = n_splits
        self.groups = groups
        self.seqtype = seqtype
        self.stratify = stratify
        self.shuffle = shuffle
        self.test_size = test_size
        self.target = target
        self.includeInTrain = includeInTrain
        self.random_state = random_state

    def get_target_id(self, X):
        """
        The function to get target type train, target indices.

        Args:
            X (numpy.ndarray): numpy.ndarray

        Returns:
            list: train and target indices.
        """
        train_ids = list()
        target_ids = list()

        target_ids = [idx for idx, elm in enumerate(self.seqtype) if elm == self.target]

        if self.includeInTrain:
            train_ids = [
                idx
                for idx, elm in enumerate(self.seqtype)
                if elm in self.includeInTrain
            ]

        return train_ids, target_ids

    def get_true_indices(self, original, generated):
        """
        The function split the target data into train
        and test data and further update main train data with
        train data from target data.

        Args:
            original (list): target indices
            generated (list): train indices from target

        Returns:
            list: indices of matched target and train indices
        """
        return [original[elm] for elm in generated]

    def split(self, X, y=None, groups=None):
        """
        The function to split data into train and test data.

        Args:
            X (numpy.ndarray): data
            y (numpy.array, optional): target values. defaults to None.
            groups (numpy.array, optional): group ids for data values. defaults to None.

        Yields:
            list: train, test indices
        """
        train_ids, target_ids = self.get_target_id(X)

        if not self.test_size:
            if self.stratify is not None:
                split_generator = StratifiedGroupKFold(
                    n_splits=self.n_splits,
                    shuffle=self.shuffle,
                    random_state=self.random_state,
                ).split(
                    X[target_ids],
                    y=self.stratify[target_ids],
                    groups=self.groups[target_ids],
                )
            else:
                split_generator = GroupKFold(n_splits=self.n_splits).split(
                    X[target_ids], groups=self.groups[target_ids]
                )

            for idx, (train_indices, val_indices) in enumerate(split_generator):
                train_indices = self.get_true_indices(target_ids, list(train_indices))
                val_indices = self.get_true_indices(target_ids, list(val_indices))

                train_indices += train_ids
                if self.shuffle:
                    train_indices = sk_utils.shuffle(
                        train_indices, random_state=self.random_state
                    )

                yield train_indices, val_indices
        else:
            if self.stratify is not None:
                count = 0
                process = True
                cv_splits = int(1 / self.test_size)
                while process:
                    split_generator = StratifiedGroupKFold(
                        n_splits=cv_splits, shuffle=True, random_state=self.random_state
                    ).split(
                        X[target_ids],
                        y=self.stratify[target_ids],
                        groups=self.groups[target_ids],
                    )
                    for idx, (train_indices, val_indices) in enumerate(split_generator):
                        train_indices = self.get_true_indices(
                            target_ids, list(train_indices)
                        )
                        val_indices = self.get_true_indices(
                            target_ids, list(val_indices)
                        )

                        train_indices += train_ids

                        if self.shuffle:
                            train_indices = sk_utils.shuffle(
                                train_indices, random_state=self.random_state
                            )

                        yield train_indices, val_indices
                        count = count + 1

                        if count == self.n_splits:
                            break
                    if count == self.n_splits:
                        process = False
            else:
                gss = GroupShuffleSplit(
                    n_splits=self.n_splits,
                    test_size=self.test_size,
                    random_state=self.random_state,
                )
                for idx, (train_indices, val_indices) in enumerate(
                    gss.split(X[target_ids], groups=self.groups[target_ids])
                ):
                    train_indices = self.get_true_indices(
                        target_ids, list(train_indices)
                    )
                    val_indices = self.get_true_indices(target_ids, list(val_indices))

                    train_indices += train_ids

                    if self.shuffle:
                        train_indices = sk_utils.shuffle(
                            train_indices, random_state=self.random_state
                        )

                    yield train_indices, val_indices

    def get_n_splits(self, X=None, y=None, groups=None):
        """
        The function to get the number of splits.

        Args:
            X (numpy.ndarray): data
            y (numpy.array, optional): target values. defaults to None.
            groups (numpy.array, optional): group ids for data values. defaults to None.

        Returns:
            scalar: number of splits.
        """
        return self.n_splits


class CustomRegressor(BaseEstimator, RegressorMixin):
    """
    Implements custom calibrated regressor based on
    trained models.
    """

    def __init__(self, best_offset=0, pipe_model=None, model="model_rasi"):
        self.best_offset = best_offset
        self.pipe_model = pipe_model
        self.model = model

    def fit(self, X, y):
        return self

    def predict(self, X):
        if self.model == "model_rasi":
            return self.pipe_model.predict(X[:, :-1]) - self.best_offset * X[:, -1]
        else:
            return self.pipe_model.predict(X) - self.best_offset * X[:, -1]

    def get_params(self, deep=True):
        return {
            "best_offset": self.best_offset,
            "pipe_model": self.pipe_model,
            "model": self.model,
        }

    def set_params(self, **parameters):
        for parameter, value in parameters.items():
            setattr(self, parameter, value)
        return self


class Model:
    """
    Implementation of Model class.
    """

    def __init__(
        self,
        model_rasi,
        model_sglt2i,
        model_mcra,
        file_csv,
        directory,
        **kwargs,
    ):
        self.config = kwargs["config_params"]
        self.threshold = eval(self.config["TC_threshold"])
        self.args = kwargs["arg_params"]
        self.model_rasi = model_rasi
        self.model_sglt2i = model_sglt2i
        self.model_mcra = model_mcra

        if self.args.train:
            self.trained_data_path = (
                self.config["trained_data_directory"] + "train_data.csv"
            )
            self.base_model_directory = self.config["trained_models_directory"]
            self.new_data_csv = self.config["train_data"]
            self.training_params = get_train_features(
                self.model_rasi, self.model_sglt2i, self.model_mcra, self.new_data_csv
            )
            self.to_train = self.args.train
        else:
            self.file = file_csv
            self.directory = directory

            if self.config["Plot"]["get_plot"] not in ["True", "False"] or self.config["Plot"]["plot_all_features"] not in ["True", "False"]:
                with open(log_dir_name, "a") as logfile:
                    logfile.write(
                        f"{datetime.now()}: Wrong bool type for Plot parameters in config.json file. Parameters must be either True or False\n"
                    )
                raise TypeError(
                    "Wrong bool type for Plot parameters in config.json file. Parameters must be either True or False"
                )
            self.get_plot = eval(self.config["Plot"]["get_plot"])
            self.to_train = self.args.train

            if os.path.isfile(self.file) and self.file.endswith(".csv"):
                with open(log_dir_name, "a") as logfile:
                    logfile.write(
                        f"{datetime.now()}: Validation data passed successfully\n"
                    )
            else:
                with open(log_dir_name, "a") as logfile:
                    logfile.write(
                        f"{datetime.now()}: Validation data to predict failed: Validation data must be full path to comma-separated csv file in string format\n"
                    )
                raise TypeError(
                    "Validation data must be full path to comma-separated csv file in string format"
                )
            model_names = ["RASI", "SGLT2i", "MCRA"]
            for idx, trained_model in enumerate(
                [self.model_rasi, self.model_sglt2i, self.model_mcra]
            ):
                if os.path.isfile(trained_model) and trained_model.endswith(".pkl"):
                    with open(log_dir_name, "a") as logfile:
                        logfile.write(
                            f"{datetime.now()}: {model_names[idx]} model passed successfully\n"
                        )
                else:
                    with open(log_dir_name, "a") as logfile:
                        logfile.write(
                            f"{datetime.now()}: {model_names[idx]} model failed: Saved model must be full path to pickle (.pkl) file in string format\n"
                        )
                    raise TypeError(
                        "Saved model must be full path to pickle (.pkl) file in string format"
                    )

            if (
                os.path.isdir(get_directory(self.directory))
                and self.directory.endswith(".csv")
                and isinstance(self.directory, str)
            ):
                pass
            else:
                with open(log_dir_name, "a") as logfile:
                    logfile.write(
                        f"{datetime.now()}: Wrong output directory name: Directory must be full path to output file (.csv) in string format.\nExample: ./outputs/TC_pred.csv\n"
                    )
                raise TypeError(
                    "Directory must be full path to output file in string format"
                )

    def preprocess(self):
        """
        The function preprocess given new data.

        Returns:
           DataFrame: preprocessed data.
        """
        # import data
        if self.to_train:
            df = pd.read_csv(self.new_data_csv, sep=",")
            df = df.sort_values(by=["SUID", "SEQID", "DV"])
            df.reset_index(drop=True, inplace=True)
            df["EGFR_next"] = df.groupby(["SUID", "SEQID"])["EGFR"].shift(-1)
            df["TC_true"] = df.filter(["EGFR", "EGFR_next"]).apply(
                lambda x: TC_convert(x, thresh=self.threshold), axis=1
            )
        else:
            df = pd.read_csv(self.file, sep=",")

        # check whether dataset has all variables that are required for modeling
        # load the model variables
        available_models = [self.model_rasi, self.model_sglt2i, self.model_mcra]
        complete_vars = set()
        composite_vars = {'PHCADB_PHCVDB'}
        for target_model in available_models:
            with open(target_model, "rb") as f:
                _, features, _ = pickle.load(f)

            complete_vars.update(features)

        complete_vars -= composite_vars
        for var in composite_vars:
            complete_vars.update(re.split('_', var))

        check_variables_inclusion(df, complete_vars)


        # log and sqrt transformations
        df["UACR"] = df["UACR"] + 1
        df["CST3_num"] = df["CST3_num"] + 1
        self.log_vars = [
            "BMI",
            "SPOT",
            "UACR",
            "PHOS_CL_num",
            "MMP7_LUM_num",
            "LEP_LUM_num",
            "TNFRSF1A_LUM_num",
            "LGALS3_LUM_num",
            "ADIPOQ_LUM_num",
            "EGF_MESO_num_norm",
            "FGF21_MESO_num_norm",
            "IL6_MESO_num_norm",
            "MMP2_MESO_num_norm",
            "LCN2_MESO_num_norm",
            "NPHS1_MESO_num_norm",
            "THBS1_MESO_num_norm",
            "CST3_num",
        ]
        self.sqrt_vars = [
            "AGER_LUM_num",
            "IL18_LUM_num",
            "CCL2_MESO_num_norm",
        ]

        # log transform
        df.loc[:, self.log_vars] = (df.loc[:, self.log_vars] + 1).transform("log")
        df.loc[:, self.sqrt_vars] = df.filter(self.sqrt_vars).transform("sqrt")
        df.replace([np.inf, -np.inf], np.nan, inplace=True)

        # categorical transformations
        # convert to numeric values
        df["GE"] = df["GE"].map({"Male": 1, "Female": 0})
        df["SDMAV"] = df["SDMAV"].map({True: 1, False: 0})
        df["PHDRB"] = df["PHDRB"].map({True: 1, False: 0})
        df["PHHFB"] = df["PHHFB"].map({True: 1, False: 0})
        df["PHCADB"] = df["PHCADB"].map({True: 1, False: 0})
        df["PHCVDB"] = df["PHCVDB"].map({True: 1, False: 0})
        df["PHCADB_PHCVDB"] = (df["PHCADB"] + df["PHCVDB"]).map(
            {0.0: 0, 1.0: 1, 2.0: 1, 3.0: 1}
        )
        df.drop(["PHCADB", "PHCVDB"], axis=1, inplace=True)

        if self.to_train:
            df.dropna(inplace=True, subset=["TC_true", "EGFR", "EGFR_next"])

        df.reset_index(drop=True, inplace=True)

        with open(log_dir_name, "a") as logfile:
            logfile.write(f"{datetime.now()}: Data processing passed successfully\n")

        return df

    def train(self):
        """The function retrains the models based on given new data.

        Returns:
            None: update models and shap datas.
        """
        X_new = self.preprocess()
        trained_data = pd.read_csv(self.trained_data_path, sep=",")
        updated_train_data = pd.concat(
            [trained_data.filter(X_new.columns.to_list()), X_new]
        ).reset_index(drop=True)

        for target_model in self.training_params:
            target = self.training_params[target_model][0]
            data_params = self.training_params[target_model][1]
            train_features = self.training_params[target_model][2]

            with open(log_dir_name, "a") as logfile:
                logfile.write(
                    f"{datetime.now()}: Training in progress for model {target_model}...\n"
                )
            ######################################################################
            # GET OFFSET
            ######################################################################
            includeInTrain = eval(data_params[0])
            shuffle = bool(data_params[1])
            test_size = data_params[3]
            stratify = bool(data_params[2])
            random_state = 7
            n_jobs = -1

            ml = updated_train_data.copy(deep=True)
            cv_split = 10

            ml = ml[ml["SEQTYPE"].isin(includeInTrain + [target])]
            ml.reset_index(drop=True, inplace=True)

            EGFR_ml = ml["EGFR"]
            EGFR_next = ml["EGFR_next"]

            TC_true_ml = ml["TC_true"]
            groups = ml["SUID"]
            seqtype = ml["SEQTYPE"]

            ml = ml.filter(train_features)
            ml = ml.astype(float)
            ml.reset_index(drop=True, inplace=True)

            y = EGFR_next.values
            X = ml.values

            target_discrete = TC_true_ml.values
            stratify = bool(data_params[2])
            if stratify:
                stratify = target_discrete
            else:
                stratify = None

            # Outer Loops
            split = cv_split

            cv = CustomCrossValidation(
                seqtype=seqtype,
                groups=groups,
                n_splits=split,
                stratify=stratify,
                shuffle=shuffle,
                target=target,
                includeInTrain=includeInTrain,
                test_size=test_size,
                random_state=random_state,
            )

            pipe = Pipeline(
                [
                    ("scl", StandardScaler()),
                    ("imp", KNNImputer(n_neighbors=7)),
                    ("clf", Lasso(random_state=random_state)),
                ]
            )

            params = {"clf__alpha": np.arange(0.0001, 1, 0.01)}

            # apply hyper-parameter tuning
            pipe_model = GridSearchCV(
                estimator=pipe,
                param_grid=params,
                cv=cv,
                n_jobs=n_jobs,
                scoring="neg_mean_squared_error",
            )

            pipe_model = TransformedTargetRegressor(
                regressor=pipe_model, func=np.log, inverse_func=np.exp
            )

            # fit model
            pipe_model.fit(X, y)

            y_pred = pipe_model.predict(X[seqtype == target])
            y = y[seqtype == target]

            EGFR = EGFR_ml[seqtype == target].values
            TC_true = TC_true_ml[seqtype == target].values

            thr_best = None
            best_SnSp = float("-inf")
            MAX_ALLOWED_MSE = 150
            for thr in np.linspace(-0.15, 0.15, 1000):
                prediction = pd.DataFrame(
                    data={"EGFR": EGFR, "EGFR_next_predicted": y_pred}
                )
                prediction = np.array(
                    prediction.apply(lambda x: TC_convert(x, thresh=thr), axis=1)
                )
                pred = pd.DataFrame(
                    data={
                        "target": TC_true,
                        "prediction": prediction,
                        "EGFR": EGFR,
                        "EGFR_next": y,
                        "EGFR_next_pred": y_pred,
                    }
                )
                truth = np.array(pred.target)
                prediction = np.array(pred.prediction)

                cm = ConfusionMatrix(
                    truth, prediction, classes=["controlled", "uncontrolled"]
                )
                mse = mean_squared_error(y_pred, y)
                Sn = cm.TPR["uncontrolled"]
                Sp = cm.TPR["controlled"]

                if Sn + Sp > best_SnSp:
                    thr_temp = thr
                    offset_temp = thr_temp - self.threshold

                    y_pred_updated = y_pred - offset_temp * EGFR
                    mse_thr = mean_squared_error(y_pred_updated, y)
                    if mse_thr > MAX_ALLOWED_MSE:
                        continue

                    thr_best = thr
                    offset = thr_best - self.threshold

                    prediction = pd.DataFrame(
                        data={"EGFR": EGFR, "EGFR_next_predicted": y_pred_updated}
                    )
                    prediction = np.array(
                        prediction.apply(
                            lambda x: TC_convert(x, thresh=self.threshold), axis=1
                        )
                    )
                    pred = pd.DataFrame(
                        data={
                            "target": TC_true,
                            "prediction": prediction,
                            "EGFR": EGFR,
                            "EGFR_next": y,
                            "EGFR_next_pred": y_pred_updated,
                        }
                    )
                    truth = np.array(pred.target)
                    prediction = np.array(pred.prediction)

                    cm = ConfusionMatrix(
                        truth, prediction, classes=["controlled", "uncontrolled"]
                    )
                    mse = mean_squared_error(y_pred_updated, y)
                    Sn = cm.TPR["uncontrolled"]
                    Sp = cm.TPR["controlled"]
                    AUC = cm.AUC["controlled"]
                    ACC = cm.ACC["controlled"]

                    best_SnSp = Sn + Sp

            ######################################################################
            # CROSS-VALIDATED OFFSET CHECK
            ######################################################################
            if offset is not None:
                offset_indicator = [0, 1]
                random_numbers = [785, 1, 352, 456, 565, 106, 632, 53, 129, 822]
                result_SNSP = []

                for offset_ind in offset_indicator:
                    y_Test = list()
                    y_Pred = list()
                    test_Sn = list()
                    test_Sp = list()
                    test_auc = list()
                    test_acc = list()
                    test_mse = list()

                    for random_number in random_numbers:
                        test_idx = (
                            updated_train_data.query("SEQTYPE==@target")
                            .sample(frac=0.1, random_state=random_number, replace=False)
                            .index.to_list()
                        )
                        train_idx = list(
                            set(updated_train_data.index.to_list()) - set(test_idx)
                        )
                        df_train = updated_train_data.iloc[train_idx, :].reset_index(
                            drop=True
                        )
                        df_test = updated_train_data.iloc[test_idx, :].reset_index(
                            drop=True
                        )

                        ###########################################################
                        # TRAIN PHASE
                        ###########################################################

                        ml = df_train.copy(deep=True)
                        cv_split = 10
                        includeInTrain = eval(data_params[0])
                        shuffle = bool(data_params[1])
                        test_size = data_params[3]
                        stratify = bool(data_params[2])

                        ml = ml[ml["SEQTYPE"].isin(includeInTrain + [target])]
                        ml.reset_index(drop=True, inplace=True)

                        EGFR_ml = ml["EGFR"]
                        EGFR_next = ml["EGFR_next"]
                        TC_true_ml = ml["TC_true"]
                        groups = ml["SUID"]
                        seqtype = ml["SEQTYPE"]

                        ml = ml.filter(train_features)
                        ml = ml.astype(float)
                        ml.reset_index(drop=True, inplace=True)

                        y = EGFR_next.values
                        X = ml.values

                        target_discrete = TC_true_ml.values

                        if stratify:
                            stratify = target_discrete
                        else:
                            stratify = None

                        # Outer Loops
                        split = cv_split

                        cv = CustomCrossValidation(
                            seqtype=seqtype,
                            groups=groups,
                            n_splits=split,
                            stratify=stratify,
                            shuffle=shuffle,
                            target=target,
                            includeInTrain=includeInTrain,
                            test_size=test_size,
                            random_state=random_state,
                        )

                        pipe = Pipeline(
                            [
                                ("scl", StandardScaler()),
                                ("imp", KNNImputer(n_neighbors=7)),
                                ("clf", Lasso(random_state=random_state)),
                            ]
                        )

                        params = {"clf__alpha": np.arange(0.0001, 1, 0.01)}

                        # apply hyper-parameter tuning
                        pipe_model = GridSearchCV(
                            estimator=pipe,
                            param_grid=params,
                            cv=cv,
                            n_jobs=n_jobs,
                            scoring="neg_mean_squared_error",
                        )

                        pipe_model = TransformedTargetRegressor(
                            regressor=pipe_model, func=np.log, inverse_func=np.exp
                        )

                        # fit model
                        pipe_model.fit(X, y)

                        ###########################################################
                        # TEST PHASE
                        ###########################################################

                        ml = df_test.copy(deep=True)
                        cv_split = 10
                        includeInTrain = eval(data_params[0])
                        shuffle = bool(data_params[1])
                        test_size = data_params[3]
                        stratify = bool(data_params[2])

                        ml = ml[ml["SEQTYPE"].isin(includeInTrain + [target])]
                        ml.reset_index(drop=True, inplace=True)

                        EGFR_ml = ml["EGFR"]
                        EGFR_next = ml["EGFR_next"]
                        TC_true_ml = ml["TC_true"]
                        groups = ml["SUID"]
                        seqtype = ml["SEQTYPE"]

                        ml = ml.filter(train_features)
                        ml = ml.astype(float)
                        ml.reset_index(drop=True, inplace=True)

                        y = EGFR_next.values
                        X = ml.values

                        y_pred = pipe_model.predict(X)

                        EGFR = EGFR_ml.values
                        TC_true = TC_true_ml.values

                        y_pred_updated = y_pred - (offset_ind * offset * EGFR)

                        prediction = pd.DataFrame(
                            data={"EGFR": EGFR, "EGFR_next_predicted": y_pred_updated}
                        )
                        prediction = np.array(
                            prediction.apply(
                                lambda x: TC_convert(x, thresh=self.threshold), axis=1
                            )
                        )
                        pred = pd.DataFrame(
                            data={
                                "target": TC_true,
                                "prediction": prediction,
                                "EGFR": EGFR,
                                "EGFR_next": y,
                                "EGFR_next_pred": y_pred_updated,
                            }
                        )
                        truth = np.array(pred.target)
                        prediction = np.array(pred.prediction)

                        cm = ConfusionMatrix(
                            truth, prediction, classes=["controlled", "uncontrolled"]
                        )
                        mse = mean_squared_error(y_pred_updated, y)
                        Sn = cm.TPR["uncontrolled"]
                        Sp = cm.TPR["controlled"]
                        AUC = cm.AUC["controlled"]
                        ACC = cm.ACC["controlled"]

                        y_Test.append(y)
                        y_Pred.append(y_pred_updated)
                        test_Sn.append(Sn)
                        test_Sp.append(Sp)
                        test_auc.append(AUC)
                        test_acc.append(ACC)
                        test_mse.append(mse)

                    result_SNSP.append(np.mean(list(map(add, test_Sn, test_Sp))))

            if result_SNSP[1] < result_SNSP[0]:
                offset = None
                thr_best = None

            ######################################################################
            # TRAIN FINAL MODEL
            ######################################################################
            ml = updated_train_data.copy(deep=True)
            cv_split = 10

            ml = ml[ml["SEQTYPE"].isin(includeInTrain + [target])]
            ml.reset_index(drop=True, inplace=True)

            EGFR_ml = ml["EGFR"]
            EGFR_next = ml["EGFR_next"]
            TC_true_ml = ml["TC_true"]
            groups = ml["SUID"]
            seqtype = ml["SEQTYPE"]

            ml = ml.filter(train_features)
            ml = ml.astype(float)
            ml.reset_index(drop=True, inplace=True)

            y = np.log(EGFR_next.values)
            X = ml.values

            target_discrete = TC_true_ml.values
            stratify = bool(data_params[2])
            if stratify:
                stratify = target_discrete
            else:
                stratify = None

            # Outer Loops
            split = cv_split
            cv = CustomCrossValidation(
                seqtype=seqtype,
                groups=groups,
                n_splits=split,
                stratify=stratify,
                shuffle=shuffle,
                target=target,
                includeInTrain=includeInTrain,
                test_size=test_size,
                random_state=random_state,
            )

            params = {
                "clf__max_depth": scope.int(hp.quniform("clf__max_depth", 3, 150, 1)),
                "clf__gamma": hp.uniform("clf__gamma", 0.3, 9),
                "clf__reg_alpha": hp.loguniform("clf__reg_alpha", -5, 3),
                "clf__reg_lambda": hp.loguniform("clf__reg_lambda", -5, 3),
                "clf__colsample_bytree": hp.uniform("clf__colsample_bytree", 0.5, 1),
                "clf__min_child_weight": hp.quniform("clf__min_child_weight", 0, 10, 1),
                "clf__n_estimators": scope.int(
                    hp.quniform("clf__n_estimators", 5, 350, 1)
                ),
                "clf__learning_rate": hp.uniform("clf__learning_rate", 0, 1),
                "clf__subsample": hp.uniform("clf__subsample", 0.1, 1),
            }

            def objective_function(params):
                pipe_xgboost = Pipeline(
                    [
                        ("scl", StandardScaler()),
                        (
                            "clf",
                            XGBRegressor(
                                **params,
                                booster="gblinear",
                                tree_method="exact",
                                n_jobs=n_jobs,
                                objective="reg:squarederror",
                                verbosity=0,
                                random_state=random_state,
                            ),
                        ),
                    ]
                )
                score = cross_val_score(
                    pipe_xgboost, X, y, cv=cv, scoring="neg_mean_squared_error"
                ).mean()
                return {"loss": -score, "status": STATUS_OK}

            trials = Trials()
            num_eval = 100000

            # best optimal parameters
            best = fmin(
                objective_function,
                params,
                algo=tpe.suggest,
                max_evals=num_eval,
                trials=trials,
                verbose=0,
                early_stop_fn=no_progress_loss(1000),
            )

            # Define pipeline
            pipe_model = Pipeline(
                [
                    ("scl", StandardScaler()),
                    ("imp", KNNImputer(n_neighbors=7)),
                    (
                        "clf",
                        XGBRegressor(
                            **best,
                            booster="gblinear",
                            tree_method="exact",
                            n_jobs=n_jobs,
                            objective="reg:squarederror",
                        ),
                    ),
                ]
            )

            pipe_model = TransformedTargetRegressor(
                regressor=pipe_model, func=np.log, inverse_func=np.exp
            )

            y = np.exp(y[:])

            # fit model
            pipe_model.fit(X, y)

            now = datetime.now()
            label = (
                "model_"
                + target_model
                + "_"
                + str(now.day)
                + str(now.month)
                + str(now.year)
                + str(now.hour)
                + str(now.minute)
                + ".pkl"
            )
            label = self.base_model_directory + label

            # save model
            with open(label, "wb") as f:
                pickle.dump([pipe_model, train_features, thr_best], f)

            # update shap_data
            ml = updated_train_data.copy(deep=True)
            if target_model == "rasi":
                ml = ml[ml["SEQTYPE"].isin([target])]
                new_features = train_features[:] + ["EGFR"]
            else:
                ml = ml[ml["SEQTYPE"].isin([target, "0r"])]
                new_features = train_features[:]
            ml = ml.filter(new_features)
            ml = ml.astype(float)
            ml.reset_index(drop=True, inplace=True)
            shap_directory = (
                self.config["trained_data_directory"] + "shap_" + target_model + ".csv"
            )
            ml.to_csv(shap_directory, header=True, index=False, sep=",")

            with open(log_dir_name, "a") as logfile:
                logfile.write(
                    f"{datetime.now()}: Training phase for {target_model} finished successfully\n"
                )

        # update train_data
        updated_train_data.to_csv(
            self.trained_data_path, sep=",", header=True, index=False
        )

    def predict(self):
        """
        The function predicts target based on given new test data and
        create performance metrics.
        """
        X_main = self.preprocess()

        with open(log_dir_name, "a") as logfile:
            logfile.write(f"{datetime.now()}: Prediction in progress...\n")

        EGFR = X_main["EGFR"].values
        AGGID = X_main["AGGID"].values
        df = pd.DataFrame(data={"AGGID": AGGID})

        # load the trained model
        models = [self.model_rasi, self.model_sglt2i, self.model_mcra]
        for target_model in models:
            with open(target_model, "rb") as f:
                model, features, thr = pickle.load(f)

            if thr is not None:
                offset = thr - self.threshold

            # Predict
            X = X_main[features].values

            if target_model == self.model_rasi:
                if thr is not None:
                    X = np.append(X, EGFR.reshape(-1, 1), axis=1)
                    model = CustomRegressor(best_offset=offset, pipe_model=model)
                y_pred = model.predict(X)

                TC_pred = "TC_pred_rasi"
                Pred_delta = "Pred_delta_rasi"
                Pred_eGFR = "Pred_eGFR_rasi"

                shap_file = self.config["trained_data_directory"] + "shap_rasi.csv"
                dir_name = config["Plot"]["output_directory_shap_rasi"]
                dir_name = Path(dir_name)
                image_dir = config["Plot"]["output_directory_shap_rasi"] + "AGGID_"
            elif target_model == self.model_sglt2i:
                if thr is not None:
                    model = CustomRegressor(
                        best_offset=offset, pipe_model=model, model="model_sglt2i"
                    )
                y_pred = model.predict(X)

                TC_pred = "TC_pred_sglt2i"
                Pred_delta = "Pred_delta_sglt2i"
                Pred_eGFR = "Pred_eGFR_sglt2i"

                shap_file = self.config["trained_data_directory"] + "shap_sglt2i.csv"
                dir_name = config["Plot"]["output_directory_shap_sglt2i"]
                dir_name = Path(dir_name)
                image_dir = config["Plot"]["output_directory_shap_sglt2i"] + "AGGID_"
            else:
                if thr is not None:
                    model = CustomRegressor(
                        best_offset=offset, pipe_model=model, model="model_mcra"
                    )
                y_pred = model.predict(X)

                TC_pred = "TC_pred_mcra"
                Pred_delta = "Pred_delta_mcra"
                Pred_eGFR = "Pred_eGFR_mcra"

                shap_file = self.config["trained_data_directory"] + "shap_mcra.csv"
                dir_name = config["Plot"]["output_directory_shap_mcra"]
                dir_name = Path(dir_name)
                image_dir = config["Plot"]["output_directory_shap_mcra"] + "AGGID_"

            prediction = pd.DataFrame(data={"EGFR": EGFR, "y_pred": y_pred})
            prediction = pd.DataFrame(
                np.array(prediction.apply(lambda x: TC_convert(x), axis=1)),
                columns=[TC_pred],
            )
            prediction[Pred_delta] = (y_pred - EGFR) / EGFR
            prediction[Pred_eGFR] = y_pred

            for col in prediction.columns:
                df[col] = prediction[col]

            if self.get_plot:
                if dir_name.exists() and dir_name.is_dir():
                    shutil.rmtree(dir_name)

                os.makedirs(dir_name)

                show_all_features = eval(config["Plot"]["plot_all_features"])

                shap_data = pd.read_csv(shap_file, sep=",")

                if thr is not None and target_model == self.model_rasi:
                    if "EGFR" not in features:
                        shap_data = shap_data.filter(features + ["EGFR"])
                else:
                    shap_data = shap_data.filter(features)

                shap_features = shap_data.columns.to_list()
                explainer = shap.Explainer(
                    model.predict, shap_data.values, feature_names=shap_features
                )
                shap_values = explainer(X)

                shap_values_new = pd.DataFrame(
                    shap_values.data[:], columns=shap_features
                )

                for ft in shap_features:
                    if ft in self.log_vars:
                        if ft in ["UACR", "CST3_num"]:
                            shap_values_new[ft] = np.exp(shap_values_new[ft]) - 2
                        else:
                            shap_values_new[ft] = np.exp(shap_values_new[ft]) - 1
                    if ft in self.sqrt_vars:
                        shap_values_new[ft] = shap_values_new[ft] ** 2
                    if ft == "GE":
                        shap_values_new[ft] = shap_values_new[ft].map({1.0: "Male", 0.0: "Female"})

                shap_values.data = shap_values_new.values
                num_patients = X.shape[0]

                if target_model == self.model_rasi and thr is not None:
                    shap_values = [
                        *map(
                            functools.partial(
                                update_shap, ft="EGFR", shap_ft=shap_features
                            ),
                            shap_values,
                        )
                    ]

                for patient_idx in range(num_patients):
                    image_dir_idx = image_dir + str(AGGID[patient_idx]) + ".svg"
                    plt.cla()
                    plt.clf()
                    plt.close()
                    plt.style.use("default")
                    plt.grid(alpha=0.1)
                    if show_all_features:
                        shap.plots.waterfall(
                            shap_values[patient_idx],
                            max_display=len(features),
                            show=False,
                        )
                    else:
                        shap.plots.waterfall(shap_values[patient_idx], show=False)

                    plt.savefig(image_dir_idx, bbox_inches="tight")
                    plt.style.use("default")

        treatment = ["RASi", "RASi+SGLT2i", "RASi+MCRA"]

        optimal = df.filter(["Pred_delta_rasi", "Pred_delta_sglt2i", "Pred_delta_mcra"])
        optimal["opt_idx"] = optimal.apply(lambda x: np.argmax(x), axis=1)
        optimal["Optimal_treatment"] = optimal.filter(["opt_idx"]).apply(
            lambda x: treatment[x[0]], axis=1
        )

        df["Optimal_treatment"] = optimal["Optimal_treatment"]
        df.to_csv(self.directory, sep=",", header=True, index=False)
        with open(log_dir_name, "a") as logfile:
            logfile.write(f"{datetime.now()}: Prediction phase finished successfully\n")

        return
