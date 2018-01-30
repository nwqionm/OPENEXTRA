<?php

error_reporting(E_ALL | E_NOTICE);
$vnstat_config_format_hour = "H";
$vnstat_bin_dir = '/usr/local/bin/vnstat';
$use_predefined_interfaces = true;
$byte_formatter = "MB";

if ($use_predefined_interfaces == true) {
    $interface_list = array("eth0");

    $interface_name['eth0'] = "Internal";
} else {
    $interface_list = get_vnstat_interfaces($vnstat_bin_dir);

    foreach ($interface_list as $interface)
    {
        $interface_name[$interface] = $interface;
    }
}
?>
