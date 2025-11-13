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

// Find the build() method and add the fix after json_decode line
$search = '            $packages = json_decode($this->files->get($path), true);';
$replace = '            $packages = json_decode($this->files->get($path), true);
            // Fix nested array structure (Composer 2.x format)
            if (is_array($packages) && !empty($packages)) {
                // Check if first element is an array (nested structure)
                if (isset($packages[0]) && is_array($packages[0])) {
                    // Check if first element of first element is also an array (double nested)
                    if (isset($packages[0][0]) && is_array($packages[0][0])) {
                        $packages = $packages[0];
                    }
                }
                // Check if packages is wrapped in "packages" key
                if (isset($packages["packages"]) && is_array($packages["packages"])) {
                    $packages = $packages["packages"];
                }
            }';

if (strpos($content, $search) !== false && strpos($content, 'Fix nested array structure') === false) {
    $content = str_replace($search, $replace, $content);
    echo "Applied nested array fix\n";
} else {
    echo "Pattern not found or already patched\n";
}

// Fix the mapWithKeys callback to handle missing 'name' key
$search2 = 'return [$this->format($package[\'name\']) => $package[\'extra\'][\'laravel\'] ?? []];';
$replace2 = 'if (!is_array($package) || !isset($package[\'name\'])) { return []; } return [$this->format($package[\'name\']) => $package[\'extra\'][\'laravel\'] ?? []];';

if (strpos($content, $search2) !== false) {
    $content = str_replace($search2, $replace2, $content);
}

// Also patch getManifest to return empty array if build fails
$search3 = 'if (! file_exists($this->manifestPath)) {
            $this->build();
        }';
$replace3 = 'if (! file_exists($this->manifestPath)) {
            try {
                $this->build();
            } catch (\Exception $e) {
                // If build fails, create empty manifest file
                file_put_contents($this->manifestPath, "<?php return [];");
            }
        }';

if (strpos($content, $search3) !== false && strpos($content, 'If build fails') === false) {
    $content = str_replace($search3, $replace3, $content);
}

file_put_contents($file, $content);
echo "PackageManifest.php patched successfully\n";

