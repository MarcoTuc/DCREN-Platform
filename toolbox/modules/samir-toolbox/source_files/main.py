from utils import Model, config, args


if __name__ == "__main__":
    model = Model(
        config["directory_rasi_model"],
        config["directory_sglt2i_model"],
        config["directory_mcra_model"],
        config["predict_data"],
        config["output_directory"],
        config_params=config,
        arg_params=args,
    )
    if args.train:
        model.train()
    else:
        model.predict()
