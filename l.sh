#!/bin/bash

cat > /var/www/html/vnstat/vnstat.php <<END
<?php

// $wSuf (without suffix MB, GB, etc)
function kbytes_to_string($kb, $wSuf = false, $byte_notation = null) {
    $units = array('TB', 'GB', 'MB', 'KB');
    $scale = 1024 * 1024 * 1024;
    $ui = 0;
    
    $custom_size = isset($byte_notation) && in_array($byte_notation, $units);

    while ((($kb < $scale) && ($scale > 1)) || $custom_size) {
        $ui++;
        $scale = $scale / 1024;

        if ($custom_size && $units[$ui] == $byte_notation) {
            break;
        }
    }

    if ($wSuf == true) {
        return sprintf("%0.2f", ($kb / $scale));
    } else {
        return sprintf("%0.2f %s", ($kb / $scale), $units[$ui]);
    }
}

function get_vnstat_interfaces($path) {
    $vnstat_interfaces = array(); // Create an empty array

    $vnstatIF = popen("$path --iflist", "r");
    if (is_resource($vnstatIF)) {
        $iBuffer = '';
        while (!feof($vnstatIF)) {
            $iBuffer .= fgets($vnstatIF);
        }

        $vnstat_temp = trim(str_replace("Available interfaces: ", "", $iBuffer));

        $vnstat_interfaces = explode(" ", $vnstat_temp);
        pclose($vnstatIF);
    }

    return $vnstat_interfaces;
}

function get_largest_value($array) {
    return $max = array_reduce($array, function($a, $b) {
        return $a > $b['totalUnformatted'] ? $a : $b['totalUnformatted'];
    });
}

function get_largest_prefix($kb) {
    $units = array('TB', 'GB', 'MB', 'KB');
    $scale = 1024 * 1024 * 1024;
    $ui = 0;

    while ((($kb < $scale) && ($scale > 1))) {
        $ui++;
        $scale = $scale / 1024;
    }

    return $units[$ui];
}

function get_vnstat_data($path, $type, $interface) {
    global $byte_formatter, $vnstat_config_format_hour;
    
    $vnstat_information = array(); // Create an empty array for use later

    $vnstatDS = popen("$path --dumpdb -i $interface", "r");
    //$vnstatDS = fopen("dump.db", "r");
    if (is_resource($vnstatDS)) {
        $buffer = '';
        while (!feof($vnstatDS)) {
            $buffer .= fgets($vnstatDS);
        }
        $vnstat_information = explode("\n", $buffer);
        pclose($vnstatDS);
    }

    if (isset($vnstat_information[0]) && strpos($vnstat_information[0], 'Error') !== false) {
        return;
    }

    $hourlyGraph = array();
    $hourly = array();
    $dailyGraph = array();
    $daily = array();
    $monthlyGraph = array();
    $monthly = array();
    $top10 = array();

    foreach ($vnstat_information as $vnstat_line) {
        $data = explode(";", trim($vnstat_line));
        switch ($data[0]) {
            case "h": // Hourly
                // Set-up the hourly graph data
                $hourlyGraph[$data[1]]['time'] = $data[2];
                $hourlyGraph[$data[1]]['label'] = date($vnstat_config_format_hour, ($data[2] - ($data[2] % 3600)));
                $hourlyGraph[$data[1]]['rx'] = kbytes_to_string($data[3], true, $byte_formatter);
                $hourlyGraph[$data[1]]['tx'] = kbytes_to_string($data[4], true, $byte_formatter);
                $hourlyGraph[$data[1]]['total'] = kbytes_to_string($data[3] + $data[4], true, $byte_formatter);
                $hourlyGraph[$data[1]]['totalUnformatted'] = ($data[3] + $data[4]);
                $hourlyGraph[$data[1]]['act'] = 1;

                // Set up the hourly table data
                $hourly[$data[1]]['time'] = $data[2];
                $hourly[$data[1]]['label'] = date($vnstat_config_format_hour, ($data[2] - ($data[2] % 3600)));
                $hourly[$data[1]]['rx'] = kbytes_to_string($data[3]);
                $hourly[$data[1]]['tx'] = kbytes_to_string($data[4]);
                $hourly[$data[1]]['total'] = kbytes_to_string($data[3] + $data[4]);
                $hourly[$data[1]]['act'] = 1;
                break;
            case "d": // Daily
                // Set-up the daily graph data
                $dailyGraph[$data[1]]['time'] = $data[2];
                $dailyGraph[$data[1]]['label'] = date("jS", $data[2]);
                $dailyGraph[$data[1]]['rx'] = kbytes_to_string(($data[3] * 1024 + $data[5]), true, $byte_formatter);
                $dailyGraph[$data[1]]['tx'] = kbytes_to_string(($data[4] * 1024 + $data[6]), true, $byte_formatter);
                $dailyGraph[$data[1]]['total'] = kbytes_to_string(($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]), true, $byte_formatter);
                $dailyGraph[$data[1]]['totalUnformatted'] = (($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]));
                $dailyGraph[$data[1]]['act'] = 1;
                
                $daily[$data[1]]['time'] = $data[2];
                $daily[$data[1]]['label'] = date("d/m/Y", $data[2]);
                $daily[$data[1]]['rx'] = kbytes_to_string($data[3] * 1024 + $data[5]);
                $daily[$data[1]]['tx'] = kbytes_to_string($data[4] * 1024 + $data[6]);
                $daily[$data[1]]['total'] = kbytes_to_string(($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]));
                $daily[$data[1]]['act'] = $data[7];
                break;
            case "m": // Monthly
                // Set-up the monthly graph data
                $monthlyGraph[$data[1]]['time'] = $data[2];
                $monthlyGraph[$data[1]]['label'] = date("F", ($data[2] - ($data[2] % 3600)));
                $monthlyGraph[$data[1]]['rx'] = kbytes_to_string(($data[3] * 1024 + $data[5]), true, $byte_formatter);
                $monthlyGraph[$data[1]]['tx'] = kbytes_to_string(($data[4] * 1024 + $data[6]), true, $byte_formatter);
                $monthlyGraph[$data[1]]['total'] = kbytes_to_string((($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6])), true, $byte_formatter);
                $monthlyGraph[$data[1]]['totalUnformatted'] = ($data[3] + $data[4]);
                $monthlyGraph[$data[1]]['act'] = 1;
                
                $monthly[$data[1]]['time'] = $data[2];
                $monthly[$data[1]]['label'] = date("F", $data[2]);
                $monthly[$data[1]]['rx'] = kbytes_to_string($data[3] * 1024 + $data[5]);
                $monthly[$data[1]]['tx'] = kbytes_to_string($data[4] * 1024 + $data[6]);
                $monthly[$data[1]]['total'] = kbytes_to_string(($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]));
                $monthly[$data[1]]['act'] = $data[7];
                break;
            case "t": // Top 10
                $top10[$data[1]]['time'] = $data[2];
                $top10[$data[1]]['label'] = date("d/m/Y", $data[2]);
                $top10[$data[1]]['rx'] = kbytes_to_string($data[3] * 1024 + $data[5]);
                $top10[$data[1]]['tx'] = kbytes_to_string($data[4] * 1024 + $data[6]);
                $top10[$data[1]]['totalraw'] = (($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]));
                $top10[$data[1]]['total'] = kbytes_to_string(($data[3] * 1024 + $data[5]) + ($data[4] * 1024 + $data[6]));
                $top10[$data[1]]['act'] = $data[7];
                break;
        }
    }

    usort($hourlyGraph, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] < $item2['time'] ? -1 : 1;
    });

    usort($hourly, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] < $item2['time'] ? -1 : 1;
    });
    
    usort($dailyGraph, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] > $item2['time'] ? -1 : 1;
    });

    usort($daily, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] > $item2['time'] ? -1 : 1;
    });
    
    usort($monthlyGraph, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] > $item2['time'] ? -1 : 1;
    });

    usort($monthly, function ($item1, $item2) {
        if ($item1['time'] == $item2['time']) return 0;
        return $item1['time'] > $item2['time'] ? -1 : 1;
    });

    // Sort Top 10 Days by Highest Total Usage first
    usort($top10, function ($item1, $item2) {
        if ($item1['totalraw'] == $item2['totalraw']) return 0;
        return $item1['totalraw'] > $item2['totalraw'] ? -1 : 1;
    });

    switch ($type) {
        case "hourlyGraph":
            return $hourlyGraph;
        case "hourly":
            return $hourly;
        case "dailyGraph":
            return $dailyGraph;
        case "daily":
            return $daily;
        case "monthlyGraph":
            return $monthlyGraph;
        case "monthly":
            return $monthly;
        case "top10":
            return $top10;
    }
}
?>
END

cat > /var/www/html/vnstat/config.php <<END
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
END

cat > /var/www/html/vnstat/index.php <<END
<?php

require('vnstat.php');
require('config.php');

function print_options() {
    global $interface_list;

    $i = 0;
    foreach ($interface_list as $interface) {
        $i++;
        if ($i == count($interface_list)) {
            echo "<a href=\"?i=" . $interface . "\">" . $interface . "</a>";
        } else {
            echo "<a href=\"?i=" . $interface . "\">" . $interface . ", </a>";
        }
    }
}

$thisInterface = "";

if (isset($_GET['i'])) {
    $interfaceChosen = $_GET['i'];
    if (in_array($interfaceChosen, $interface_list, true)) {
        $thisInterface = $interfaceChosen;
    } else {
        $thisInterface = reset($interface_list);
    }
} else {

    $thisInterface = reset($interface_list);
}
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>BANDWIDTH</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
        <link rel="stylesheet" href="css/style.css">
        
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
        <script type="text/javascript">
            google.charts.load('current', {'packages': ['bar']});
            google.charts.setOnLoadCallback(drawHourlyChart);
            google.charts.setOnLoadCallback(drawDailyChart);
            google.charts.setOnLoadCallback(drawMonthlyChart);

            function drawHourlyChart() {
                var data = google.visualization.arrayToDataTable([
                    ['Hour', 'Bandwidth In', 'Bandwidth Out', 'Total Bandwidth'],
                    <?php
                    $hourlyGraph = get_vnstat_data($vnstat_bin_dir, "hourlyGraph", $thisInterface);

                    for ($i = 0; $i < count($hourlyGraph); $i++) {
                        $hour = $hourlyGraph[$i]['label'];
                        $inTraffic = $hourlyGraph[$i]['rx'];
                        $outTraffic = $hourlyGraph[$i]['tx'];
                        $totalTraffic = $hourlyGraph[$i]['total'];

                        if ($hourlyGraph[$i]['time'] == "0") {
                            continue;
                        }

                        if ($i == 23) {
                            echo("['" . $hour . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "]\n");
                        } else {
                            echo("['" . $hour . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "],\n");
                        }
                    }
                    ?>
                ]);

                var options = {
                    title: 'Hourly Network Bandwidth',
                    subtitle: 'over last 24 hours',
                    vAxis: {format: '##.## <?php echo $byte_formatter; ?>'}
                };

                var chart = new google.charts.Bar(document.getElementById('hourlyNetworkTrafficGraph'));
                chart.draw(data, google.charts.Bar.convertOptions(options));
            }
            function drawDailyChart() {
                var data = google.visualization.arrayToDataTable([
                    ['Day', 'Bandwidth In', 'Bandwidth Out', 'Total Bandwidth'],
                    <?php
                    $dailyGraph = get_vnstat_data($vnstat_bin_dir, "dailyGraph", $thisInterface);

                    for ($i = 0; $i < count($dailyGraph); $i++) {
                        $day = $dailyGraph[$i]['label'];
                        $inTraffic = $dailyGraph[$i]['rx'];
                        $outTraffic = $dailyGraph[$i]['tx'];
                        $totalTraffic = $dailyGraph[$i]['total'];

                        if ($dailyGraph[$i]['time'] == "0") {
                            continue;
                        }

                        if ($i == 29) {
                            echo("['" . $day . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "]\n");
                        } else {
                            echo("['" . $day . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "],\n");
                        }
                    }
                    ?>
                ]);

                var options = {
                    title: 'Daily Network Bandwidth',
                    subtitle: 'over last 29 days (most recent first)',
                    vAxis: {format: '##.## <?php echo $byte_formatter; ?>'}
                };

                var chart = new google.charts.Bar(document.getElementById('dailyNetworkTrafficGraph'));
                chart.draw(data, google.charts.Bar.convertOptions(options));
            }
            function drawMonthlyChart() {
                var data = google.visualization.arrayToDataTable([
                    ['Month', 'Bandwidth In', 'Bandwidth Out', 'Total Bandwidth'],
                    <?php
                    $monthlyGraph = get_vnstat_data($vnstat_bin_dir, "monthlyGraph", $thisInterface);

                    for ($i = 0; $i < count($monthlyGraph); $i++) {
                        $hour = $monthlyGraph[$i]['label'];
                        $inTraffic = $monthlyGraph[$i]['rx'];
                        $outTraffic = $monthlyGraph[$i]['tx'];
                        $totalTraffic = $monthlyGraph[$i]['total'];

                        if ($monthlyGraph[$i]['time'] == "0") {
                            continue;
                        }

                        if ($i == 23) {
                            echo("['" . $hour . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "]\n");
                        } else {
                            echo("['" . $hour . "', " . $inTraffic . " , " . $outTraffic . ", " . $totalTraffic . "],\n");
                        }
                    }
                    ?>
                ]);

                var options = {
                    title: 'Monthly Network Bandwidth',
                    subtitle: 'over last 12 months',
                    vAxis: {format: '##.## <?php echo $byte_formatter; ?>'}
                };

                var chart = new google.charts.Bar(document.getElementById('monthlyNetworkTrafficGraph'));
                chart.draw(data, google.charts.Bar.convertOptions(options));
            }
        </script>
    </head>
    <body>
        <div class="container">
            <div class="page-header">
                <h1>BANDWIDTH</h1>
            </div>
        </div>

        <div id="graphTabNav" class="container">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#hourlyGraph" data-toggle="tab">Hourly Graph</a></li>
                <li><a href="#dailyGraph" data-toggle="tab">Daily Graph</a></li>
                <li><a href="#monthlyGraph" data-toggle="tab">Monthly Graph</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="hourlyGraph">
                    <div id="hourlyNetworkTrafficGraph" style="height: 300px;"></div>
                </div>

                <div class="tab-pane" id="dailyGraph">
                    <div id="dailyNetworkTrafficGraph" style="height: 300px;"></div>
                </div>

                <div class="tab-pane" id="monthlyGraph">
                    <div id="monthlyNetworkTrafficGraph" style="height: 300px;"></div>
                </div>
            </div>
        </div>

        <div id="tabNav" class="container">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#hourly" data-toggle="tab">Hourly</a></li>
                <li><a href="#daily" data-toggle="tab">Daily</a></li>
                <li><a href="#monthly" data-toggle="tab">Monthly</a></li>
                <li><a href="#top10" data-toggle="tab">Top 10</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="hourly">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Hour</th>
                                <th>Received</th>
                                <th>Sent</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $hourly = get_vnstat_data($vnstat_bin_dir, "hourly", $thisInterface);

                            for ($i = 0; $i < count($hourly); $i++) {
                                $hour = $hourly[$i]['label'];
                                $totalReceived = $hourly[$i]['rx'];
                                $totalSent = $hourly[$i]['tx'];
                                $totalTraffic = $hourly[$i]['total'];
                                ?>
                                <tr>
                                    <td><?php echo $hour; ?></td>
                                    <td><?php echo $totalReceived; ?></td>
                                    <td><?php echo $totalSent; ?></td>
                                    <td><?php echo $totalTraffic; ?></td>
                                </tr>
                            <?php
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
                <div class="tab-pane" id="daily">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Day</th>
                                <th>Received</th>
                                <th>Sent</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $daily = get_vnstat_data($vnstat_bin_dir, "daily", $thisInterface);

                            for ($i = 0; $i < count($daily); $i++) {
                                if ($daily[$i]['act'] == 1) {
                                    $day = $daily[$i]['label'];
                                    $totalReceived = $daily[$i]['rx'];
                                    $totalSent = $daily[$i]['tx'];
                                    $totalTraffic = $daily[$i]['total'];
                                    ?>
                                    <tr>
                                        <td><?php echo $day; ?></td>
                                        <td><?php echo $totalReceived; ?></td>
                                        <td><?php echo $totalSent; ?></td>
                                        <td><?php echo $totalTraffic; ?></td>
                                    </tr>
                            <?php
                                }
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
                <div class="tab-pane" id="monthly">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th>Received</th>
                                <th>Sent</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $monthly = get_vnstat_data($vnstat_bin_dir, "monthly", $thisInterface);

                            for ($i = 0; $i < count($monthly); $i++) {
                                if ($monthly[$i]['act'] == 1) {
                                    $month = $monthly[$i]['label'];
                                    $totalReceived = $monthly[$i]['rx'];
                                    $totalSent = $monthly[$i]['tx'];
                                    $totalTraffic = $monthly[$i]['total'];
                                    ?>
                                    <tr>
                                        <td><?php echo $month; ?></td>
                                        <td><?php echo $totalReceived; ?></td>
                                        <td><?php echo $totalSent; ?></td>
                                        <td><?php echo $totalTraffic; ?></td>
                                    </tr>
                            <?php
                                }
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
                <div class="tab-pane" id="top10">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Day</th>
                                <th>Received</th>
                                <th>Sent</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $top10 = get_vnstat_data($vnstat_bin_dir, "top10", $thisInterface);

                            for ($i = 0; $i < count($top10); $i++) {
                                if ($top10[$i]['act'] == 1) {
                                    $day = $top10[$i]['label'];
                                    $totalReceived = $top10[$i]['rx'];
                                    $totalSent = $top10[$i]['tx'];
                                    $totalTraffic = $top10[$i]['total'];
                                    ?>
                                    <tr>
                                        <td><?php echo $day; ?></td>
                                        <td><?php echo $totalReceived; ?></td>
                                        <td><?php echo $totalSent; ?></td>
                                        <td><?php echo $totalTraffic; ?></td>
                                    </tr>
                            <?php
                                }
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>
END

cat > /var/www/html/vnstat/css/style.css <<END
.tab-content > .tab-pane:not(.active),
.pill-content > .pill-pane:not(.active) {
    display: block;
    height: 0;
    overflow-y: hidden;
} 
END
