![header](https://raw.githubusercontent.com/IORoot/standalone/refs/heads/master/header.jpg)

# Standalone

Does the simple job of finding any 'source' lines in a BASH script and replacing that line with the full contents of that source.

## Why

So you can split your BASH script up into multiple files and then 'compile' it into a single file when you're ready.

## Example

```bash
> ls
standalone.sh
program.src.sh
include_file.sh
```

### input: program.src.sh
```bash
#!/bin/bash

echo "start"

source include_file.sh

echo "finish"
```

### include_file.sh
```bash
#!/bin/bash

echo "middle"
```

### Run command

```bash
./standalone.sh --input program.src.sh --output program.sh
```

The `program.sh` will be generated with the same permissions as the source.

### output: program.sh

```bash
#!/bin/bash

echo "start"

#source include_file.sh
echo "middle"

echo "finish"
```

