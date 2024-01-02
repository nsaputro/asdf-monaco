<div align="center">

# asdf-monaco [![Build](https://github.com/nsaputro/asdf-monaco/actions/workflows/build.yml/badge.svg)](https://github.com/nsaputro/asdf-monaco/actions/workflows/build.yml) [![Lint](https://github.com/nsaputro/asdf-monaco/actions/workflows/lint.yml/badge.svg)](https://github.com/nsaputro/asdf-monaco/actions/workflows/lint.yml)

[monaco](https://docs.dynatrace.com/docs/manage/configuration-as-code) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add monaco
# or
asdf plugin add monaco https://github.com/nsaputro/asdf-monaco.git
```

monaco:

```shell
# Show all installable versions
asdf list-all monaco

# Install specific version
asdf install monaco latest

# Set a version globally (on your ~/.tool-versions file)
asdf global monaco latest

# Now monaco commands are available
monaco version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/nsaputro/asdf-monaco/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Nugroho Saputro](https://github.com/nsaputro/)
