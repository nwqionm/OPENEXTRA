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
