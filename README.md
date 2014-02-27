# NAME

Cikl - It's new $module

# SYNOPSIS

    use Cikl;

# DESCRIPTION

    These are mostly helper functions to be used within Cikl::Archive. We did some extra work to better parse timestamps and provide some internal uuid, cpu throttling and thread-batching for various Cikl functions.

# LICENSE

Copyright (C) Mike Ryan.

# AUTHOR

Mike Ryan <falter at gmail.com>

# Functions

- is\_uuid($uuid)

        Returns 1 if the argument matches /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
        Returns 0 if it doesn't

- debug($string)

        outputs debug information when called

- generate\_uuid()

        generates a random "v4" uuid and returns it as a string
