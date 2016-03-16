<?php
function interpretUname()
{
    $releaseInfo["OS Name"]      = php_uname('s');
    $releaseInfo["Kernel"]       = php_uname('r');
    $releaseInfo["Version"]      = php_uname('v');
    $releaseInfo["Machine Type"] = php_uname('m');

    $distribution["4.10"]  = array("Warty Warthog", "2.6.8");
    $distribution["5.04"]  = array("Hoary Hedgehog", "2.6.10");
    $distribution["5.10"]  = array("Breezy Badger", "2.6.12");
    $distribution["6.06"]  = array("Dapper Drake", "2.6.15");
    $distribution["6.10"]  = array("Edgy Eft", "2.6.17");
    $distribution["7.04"]  = array("Feisty Fawn", "2.6.20");
    $distribution["7.10"]  = array("Gutsy Gibbon", "2.6.22");
    $distribution["8.04"]  = array("Hardy Heron", "2.6.24");
    $distribution["8.10"]  = array("Intrepid Ibex", "2.6.27");
    $distribution["9.04"]  = array("Jaunty Jackalope", "2.6.28");
    $distribution["9.10"]  = array("Karmic Koala", "2.6.31");
    $distribution["10.04"] = array("Lucid Lynx", "2.6.32");
    $distribution["10.10"] = array("Maverick Meerkat", "2.6.35");
    $distribution["11.04"] = array("Natty Narwhal", "2.6.38");
    $distribution["11.10"] = array("Oneiric Ocelot", "3.0");
    $distribution["12.04"] = array("Precise Pangolin", "3.2");
    $distribution["12.10"] = array("Quantal Quetzal", "3.5");
    $distribution["13.04"] = array("Raring Ringtail", "3.8");
    $distribution["13.10"] = array("Saucy Salamander", "3.11");
    $distribution["14.04"] = array("Trusty Tahr", "3.13");
    $distribution["14.10"] = array("Utopic Unicorn", "3.16");
    $distribution["15.04"] = array("Vivid Vervet", "3.19.3");
    $distribution["15.10"] = array("Wily Werewolf", "4.2");

    exec('lsb_release -as', $lsb);

    $releaseInfo["Release"]            = $lsb[1];
    $releaseInfo["{$lsb[0]} Version"]  = $lsb[2];
    $releaseInfo["{$lsb[0]} Codename"] = $distribution[$lsb[2]][0];

    return $releaseInfo;
}

function checkModules($localPath)
{
    $handle = curl_init("http://{$_SERVER['HTTP_HOST']}/{$localPath}");
    curl_setopt($handle, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($handle);
    $httpCode = curl_getinfo($handle, CURLINFO_HTTP_CODE);
    curl_close($handle);
    $isAvail = ($httpCode == 404) ? false : true;
    return $isAvail;
}

$releaseInfo = interpretUname();

$apacheMods = apache_get_modules();
$phpExt = get_loaded_extensions();
sort($apacheMods, SORT_STRING | SORT_FLAG_CASE);
sort($phpExt, SORT_STRING | SORT_FLAG_CASE);

$mysqli = new mysqli("localhost", "root", "vagrant");
if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
}
$mysqlServerinfo = $mysqli->server_info;
$mysqlClientinfo = $mysqli->client_info;
$mysqli->close();

$isLinfo   = checkModules("linfo/");
$isAdminer = checkModules("adminer.php");
$isInfo    = checkModules("info.php");

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title><?= $_SERVER['HTTP_HOST']; ?></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Basic LAMP Vagrant machine with PHP <?= phpversion(); ?>">
    <meta name="author" content="Csaba Maulis">
    <link rel="stylesheet" href="css/primer.css">
    <!--[if lt IE 9]> HTML5Shiv
        <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
    <style type="text/css">
    body {
        margin-top: 16px;
    }
    .data {
        border: 1px solid #e5e5e5;
        padding: 16px;
        overflow: auto;
        line-height: 1.45;
        background-color: #f7f7f7;
        border-radius: 3px;
        font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
    }
    .multicolumn-two {
        -webkit-column-count: 2; /* Chrome, Safari, Opera */
        -moz-column-count: 2; /* Firefox */
        column-count: 2;
    }
    .multicolumn-three {
        -webkit-column-count: 3; /* Chrome, Safari, Opera */
        -moz-column-count: 3; /* Firefox */
        column-count: 3;
    }
    </style>
</head>
<body>
<div class="container">
  <h1>Vagrant Box Info </h1>
  <div class="data">
      <strong>Vagrant Box:</strong> <?= file_get_contents("/var/provision/version") ?><br>
      <strong>Hostname:</strong> <?= gethostname() ?><br>
      <strong>URL:</strong> http://<?= $_SERVER['HTTP_HOST'] ?>
  </div>
  <div class="columns">
    <div class="one-half column">
        <h2>OS</h2>
        <div class="data">
        <?php foreach ($releaseInfo as $key => $value) : ?>
        <strong><?= $key ?>:</strong> <?= $value ?><br>
        <?php endforeach ?>
        <?= ($isLinfo) ? '<a href="linfo/" target="_blank">Linfo</a>': '' ?>
    </div>
    </div>
    <div class="one-half column">
        <h2>MySQL</h2>
        <div class="data">
            <strong>MySQL Server:</strong> <?= $mysqlServerinfo ?><br><strong>MySQL Client:</strong> <?= $mysqlClientinfo ?>
        </div>
        <?php if ($isAdminer) : ?>
        <h2>Adminer</h2>
        <div class="data">
            <strong>Version</strong>: v4.2.3+php7-fix • <a href="adminer.php" target="_blank">Open</a>
        </div>
        <?php endif ?>
    </div>
  </div>
<div class="columns">
    <div class="one-half column">
        <h2>Apache</h2>
        <div class="data">
            <strong>Version:</strong> <?= apache_get_version() ?>
        </div>
        <h3>Loaded modules:</h3>
        <div class="data">
            <div  class="multicolumn-two"><?= implode("<br>", $apacheMods) ?></div>
        </div>
    </div>
    <div class="one-half column">
        <h2>PHP</h2>
        <div class="data">
            <strong>Version:</strong> <?= phpversion() ?><?= ($isInfo) ? ' • <a href="indo.php" target="_blank">phpinfo()</a>': '' ?>
        </div>
        <h3>Enabled Extension:</h3>
        <div class="data">
            <div class="multicolumn-three"><?= implode("<br>", $phpExt)?></div>
        </div>

    </div>
  </div>
<div class="columns">
    <div class="twelwe column">
        <p><strong>vagrant-boxes</strong> © 2015–2016 Csaba Maulis</p>
        <p><em>Intentionally PHP errors:</em>
        <?php
            ecce;
            homo
        ?>
    </div>
  </div>

</div>

</body>
</html>
