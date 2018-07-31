
# How to run locally

To run this app locally (on your laptop, IU HCP systems, etc..) first make sure you clone this repo somewhere on your system.

```
git clone git@github.com:brain-life/dp.git
```

Then, inside ./dp directory, create a file named config.json

To run compute_profiles


```json
{
    "dtiinit": "/N/u/some_path_to_dtiinit_output/.",
    "optimal": "/N/u/some_path_to_appA_output/fe_optimal.mat",
    "afq": "/N/u/some_patht_afq_output/output.mat",
    "command": "profile"
}

```

If you don't have the test data, you can download it from BL.

Then, you can run compute_profiles, start the matlab session and run `compute_profiles` function without any argument.


