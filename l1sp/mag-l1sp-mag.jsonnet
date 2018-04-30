local wc = import "wirecell.jsonnet";

local params = import "params.jsonnet";

local cmdline = {
    type: "wire-cell",
    data: {
        plugins: ["WireCellGen", "WireCellPgraph", "WireCellSio", "WireCellSigProc"],
        apps: ["Pgrapher"]
    }
};

local random = {
    type: "Random",
    data: {
        generator: "default",
        seeds: [0,1,2,3,4],
    }
};
local utils = [cmdline, random];

local anode = {
    type : "AnodePlane",
    data : params.elec + params.daq + params.files {
        ident : 0,
    }
};

local fieldresponse = {
    type : "Fieldresponse",
    data: {
        filename: params.files.fields,
    }
};

local magsource = {
    type: "MagnifySource",
    data: {
        filename: std.extVar("input"),
        frames: ["raw","wiener","gauss"],
        // Map between a channel mask map key name and its TTree for reading.
        cmmtree: [         
        ],
    }
};

local magsink = {
    type: "MagnifySink",
    data: {
//        input_filename: std.extVar("input"),
        output_filename: std.extVar("output"),

	// this best be made consistent
	anode: wc.tn(anode),

        // The list of tags on traces to select groups of traces
        // to form into frames.
        frames: ["raw","wiener","gauss"],

        // The list of summary tags to save as 1D hisograms.
        summaries: [],

        // The evilness includes shunting data directly from input
        // file to output file.  This allows the shunt to be
        // limited to the listed histogram categories.  The
        // possible categories include: orig, raw, decon,
        // threshold, baseline and possibly others.  If the value
        // is left unset or null then all categories known to the
        // code will be shunted.
        shunt: [],

        // Map between a channel mask map key name and its TTree for writing.
        cmmtree: [         
            //["bad", "T_bad"],
            //["lf_noisy", "T_lf"],
        ],

    },
};

local frame_sink = {            // no config
    type: "DumpFrames",
};

local mag = [magsource, magsink, anode, fieldresponse];

local fsplit = {                // no config
    type: "FrameSplitter",
};

local chsel = {
    type: "ChannelSelector",
    data: {
        // channels that will get L1SP applied
        channels: [3566, 3567, 3568, 3569, 3570, 3571, 3572, 3573, 3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 3584, 3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599, 3600, 3601, 3602, 3603, 3604, 3605, 3606, 3607, 3608, 3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 3633, 3634, 3635, 3636, 3637, 3638, 3639, 3640, 3641, 3642, 3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 3657, 3658, 3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 3669, 3670, 3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678, 3679, 3680, 3681, 3682, 3683, 3684, 3685, 3686, 3687, 3688, 3689, 3690, 3691, 3692, 3693, 3694, 3695, 3696, 3697, 3698, 3699, 3700, 3701, 3702, 3703, 3704, 3705, 3706, 3707, 3708, 3709, 3710, 3711, 3712, 3713, 3714, 3715, 3716, 3717, 3718, 3719, 3720, 3721, 3722, 3723, 3724, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 3736, 3737, 3738, 3739, 3740, 3741, 3742, 3743, 3744, 3745, 3746, 3747, 3748, 3749, 3750, 3751, 3752, 3753, 3754, 3755, 3756, 3757, 3758, 3759, 3760, 3761, 3762, 3763, 3764, 3765, 3766, 3767, 3768, 3769, 3770, 3771, 3772, 3773, 3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781, 3782, 3783, 3784, 3785, 3786, 3787, 3788, 3789, 3790, 3791, 3792, 3793, 3794, 3795, 3796, 3797, 3798, 3799, 3800, 3801, 3802, 3803, 3804, 3805, 3806, 3807, 3808, 3809, 3810, 3811, 3812, 3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833, 3834, 3835, 3836, 3837, 3838, 3839, 3840, 3841, 3842, 3843, 3844, 3845, 3846, 3847, 3848, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858, 3859, 3860, 3861, 3862, 3863, 3864, 3865, 3866, 3867, 3868, 3869, 3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879, 3880, 3881, 3882, 3883, 3884, 3885, 3886, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3894, 3895, 3896, 3897, 3898, 3899, 3900, 3901, 3902, 3903, 3904, 3905, 3906, 3907, 3908, 3909, 3910, 3911, 3912, 3913, 3914, 3915, 3916, 3917, 3918, 3919, 3920, 3921, 3922, 3923, 3924, 3925, 3926, 3927, 3928, 3929, 3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960, 3961, 3962, 3963, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 3978, 3979, 3980, 3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989, 3990, 3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026, 4027, 4028, 4029, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039, 4040, 4041, 4042, 4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050, 4051, 4052, 4053, 4054, 4055, 4056, 4057, 4058, 4059, 4060, 4061, 4062, 4063, 4064, 4065, 4066, 4067, 4068, 4069, 4070, 4071, 4072, 4073, 4074, 4075, 4076, 4077, 4078, 4079, 4080, 4081, 4082, 4083, 4084, 4085, 4086, 4087, 4088, 4089, 4090, 4091, 4092, 4093, 4094, 4095, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245, 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4278, 4279, 4280, 4281, 4282, 4283, 4284, 4285, 4286, 4287, 4288, 4289, 4290, 4291, 4292, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4302, 4303, 4304, 4305],
	

        // can pass on only the tags of traces that are actually needed.
        tags: ["raw","gauss"]
    }
};

local l1sp = {
    type: "L1SPFilter",
    data: {
        filter: [0.000305453, 0.000978027, 0.00277049, 0.00694322, 0.0153945, 0.0301973, 0.0524048, 0.0804588, 0.109289, 0.131334, 0.139629, 0.131334, 0.109289, 0.0804588, 0.0524048, 0.0301973, 0.0153945, 0.00694322, 0.00277049, 0.000978027, 0.000305453], // bogus place holder
	raw_ROI_th_nsigma: 4.2,
	raw_ROI_th_adclimit:  9,
	overall_time_offset : 0,
	collect_time_offset : 3.0,
	roi_pad: 20,
	adc_l1_threshold: 6,
	adc_sum_threshold: 160,
	adc_sum_rescaling: 90,
	adc_sum_rescaling_limit : 50,
	l1_seg_length : 120,
	l1_scaling_factor : 500,
	l1_lambda : 5,
	l1_epsilon : 0.05,
	l1_niteration : 100000,
	l1_decon_limit : 50,
	l1_resp_scale : 0.5,
	l1_col_scale : 1.15,
        l1_ind_scale : 0.5,
	adctag: "raw",                             // trace tag of raw data
        sigtag: "gauss",                           // trace tag of input signal
        outtag: "l1sp",                            // trace tag for output signal
    }
};

local fmerge = {
    type: "FrameMerger",
    data: {
        rule: "replace",

        // note: the first two need to match the order of what data is
        // fed to ports 0 and 1 of this component in the pgraph below!
        mergemap: [
            ["raw","raw","raw"],
            ["l1sp","gauss","gauss"],
            ["l1sp","wiener","wiener"],
        ],
    }
};
local flow = [chsel, l1sp, fmerge];


local app = {
    type: "Pgrapher",
    data: {
        edges: [
            {
                tail: { node: wc.tn(magsource) },
                head: { node: wc.tn(fsplit) },
            },
            {
                tail: { node: wc.tn(fsplit), port:1 },
                head: { node: wc.tn(fmerge), port:1 },
            },
            {
                tail: { node: wc.tn(fsplit), port:0 },
                head: { node: wc.tn(chsel) },
            },
            {
                tail: { node: wc.tn(chsel) },
                head: { node: wc.tn(l1sp) },
            },
            {
                tail: { node: wc.tn(l1sp) },
                head: { node: wc.tn(fmerge), port:0 },
            },
            {
                tail: { node: wc.tn(fmerge) },
                head: { node: wc.tn(magsink) },
            },
            {
                tail: { node: wc.tn(magsink) },
                head: { node: wc.tn(frame_sink) },
            },
        ],
    }        
};

utils + mag + flow + [app]
