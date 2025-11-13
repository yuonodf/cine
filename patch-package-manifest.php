<?php
// Patch PackageManifest.php to handle nested array structure in installed.json

$file = __DIR__ . '/vendor/laravel/framework/src/Illuminate/Foundation/PackageManifest.php';

if (!file_exists($file)) {
    echo "PackageManifest.php not found\n";
    exit(1);
}

$content = file_get_contents($file);

// Check if already patched
if (strpos($content, 'Fix nested array structure') !== false) {
    echo "Already patched\n";
    exit(0);
}

// Find the build() method and add the fix
$pattern = '/if \(\$this->files->exists\(\$path = \$this->vendorPath\.\'\/composer\/installed\.json\'\)\) \{' . "\n" . '            \$packages = json_decode\(\$this->files->get\(\$path\), true\);' . "\n" . '        \}/";
$replacement = 'if ($this->files->exists($path = $this->vendorPath.\'/composer/installed.json\')) {
            $packages = json_decode($this->files->get($path), true);
            // Fix nested array structure (Composer 2.x format)
            if (is_array($packages) && isset($packages[0]) && is_array($packages[0]) && isset($packages[0][0]) && is_array($packages[0][0])) {
                $packages = $packages[0];
            } elseif (is_array($packages) && isset($packages["packages"]) && is_array($packages["packages"])) {
                $packages = $packages["packages"];
            }
        }';

$content = preg_replace($pattern, $replacement, $content);

// Fix the mapWithKeys callback to handle missing 'name' key
$pattern2 = '/return \[\$this->format\(\$package\[\'name\'\]\) => \$package\[\'extra\'\]\[\'laravel\'\] \?\? \[\]\];/';
$replacement2 = 'if (!is_array($package) || !isset($package[\'name\'])) { return []; } return [$this->format($package[\'name\']) => $package[\'extra\'][\'laravel\'] ?? []];';

$content = preg_replace($pattern2, $replacement2, $content);

file_put_contents($file, $content);
echo "PackageManifest.php patched successfully\n";

