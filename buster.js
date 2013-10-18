var config = module.exports;

config["lib7f"] = {
  environment: "node",
  specs: ["spec/*.spec.coffee"],
  extensions: [require("buster-coffee")]
};
