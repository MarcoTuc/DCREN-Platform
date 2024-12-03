from runners import Runner, Module, Settings
from datamanager import DataManager
from expmanager import Exp
from toolbox import Toolbox
from validator import Validator

exp = Exp()
val = Validator()
dat = DataManager("dcren-datasocket_multiline.csv")

for path in exp.expdb['PATH']:
    print(path)
    valdf = val.default_dcren_validation(path)


    