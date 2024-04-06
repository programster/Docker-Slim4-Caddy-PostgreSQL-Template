<?php
require_once(__DIR__ . '/defines.php');
require_once(__DIR__ . '/vendor/autoload.php');


$dotenv = new Symfony\Component\Dotenv\Dotenv();
$dotenv->overload('/.env');

$requiredEnvVars = array(
    "ENVIRONMENT",
    "DB_USER",
    "DB_PASSWORD",
    "DB_NAME",
    "DB_HOST",
);

foreach ($requiredEnvVars as $requiredEnvVar)
{
    if (array_key_exists($requiredEnvVar, $_ENV) === false)
    {
        throw new Exception("Required environment variable not set: " . $requiredEnvVar);
    }
}

define('ENVIRONMENT', $_ENV['ENVIRONMENT']);
define('DB_HOST', $_ENV['DB_HOST']);
define('DB_USER', $_ENV['DB_USER']);
define('DB_PASSWORD', $_ENV['DB_PASSWORD']);
define('DB_NAME', $_ENV['DB_NAME']);

$autoloader = new \iRAP\Autoloader\Autoloader([
    __DIR__,
    __DIR__ . "/controllers",
    __DIR__ . "/exceptions",
    __DIR__ . "/libs",
    __DIR__ . "/middleware",
    __DIR__ . "/models",
    __DIR__ . "/models/orm",
    __DIR__ . "/views",
]);
