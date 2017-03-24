## Initialize remote backend using Consul
```
terraform remote config \
  -backend=consul \
  -backend-config="address=127.0.0.1:8500" \
  -backend-config="path=orca"
```

## See remote state json
`consul kv get orca`

## Delete remote state
`consul kv delete orca`
