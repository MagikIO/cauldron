function package_manifest_has_typescript
    if test -f package.json
        if cat package.json | jq -e '.devDependencies.typescript' >/dev/null || cat package.json | jq -e '.dependencies.typescript' >/dev/null
            return 0 # success
        else
            return 1 # not found in dependencies
        end
    else
        return 1 # package.json not found
    end
end
