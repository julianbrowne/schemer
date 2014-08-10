# Schemer

Schemer recursively reads a directory full of JSON docs and works out what the 'master' JSON schema would be to define them all. It does this by generating a JSON schema for each doc in turn and then using deltas between the schemas to produce a master. Once a master schema is produced it sanity checks it by doing a compatibility check against each JSON document previously read.

The master schema is then written to a docson directory and can be viewed in a browser.

## Installation

    git clone https://github.com/julianbrowne/schemer.git

## Running

    cd schemer

    schemer example     # runs against the 'example' directory

## Configuration

Some fields may have allowable values that are known about but do not exist in the source files. For example, if all JSON documents contain an ``email`` field then the schema will mark this as a mandatory string. If some contain an ``email`` field, but others do not, then the field will be marked as optional but still mandated as a string when it is present. To set the email field to allow nulls, add ``email`` to the ``fields_that_can_be_null`` list in ``config.yml``. The setting should be the full path as seen in the JSON file but without the prefix ``properties`` or ``type`` found in the JSON schema file.

e.g. to allow the ``age`` field in ``{ "name": "bob", "stats": { "age": 42 } }`` to be present but ``null`` in some JSON documents, the config file should look like this:

    fields_that_can_be_null:
        - stats.age
