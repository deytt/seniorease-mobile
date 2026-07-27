#!/bin/bash
# Corrige o deployment target do FlutterGeneratedPluginSwiftPackage após flutter pub get.
# Firebase SDK 12+ exige iOS 15.0, mas o Flutter gera o Package.swift com 13.0 por padrão.

PACKAGE_SWIFT="ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"

if [ -f "$PACKAGE_SWIFT" ]; then
    sed -i '' 's/.iOS("13.0")/.iOS("15.0")/g' "$PACKAGE_SWIFT"
    echo "✅ iOS deployment target corrigido para 15.0 em $PACKAGE_SWIFT"
else
    echo "⚠️  $PACKAGE_SWIFT não encontrado. Execute flutter pub get primeiro."
fi
