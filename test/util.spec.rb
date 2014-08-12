
dir = File.dirname(__FILE__)

$: << File.expand_path("#{dir}/../lib")
$: << File.expand_path("#{dir}/../test")

require "test/unit"
require "tuff"
require "util"

class SchemaTest < Test::Unit::TestCase

    def test_generate_name

        r1 = Util.generate_name 'key', 'parent'
        assert_equal(r1, 'parent.key')

        r2 = Util.generate_name 'key', 'parent.0'
        assert_equal(r2, 'parent[n].key')

        r3 = Util.generate_name 'key.0', nil
        assert_equal(r3, 'key[n]')

    end

    def test_json_keys

        hash = {'a' => { 'b' => { 'c' => { 'd' => 10 }, 'e' => 20 }}}
        r1 = Util.json_keys hash
        assert_equal(r1, ['a', 'a.b', 'a.b.c', 'a.b.c.d', 'a.b.e'])

        hash = [ 'a', 'b', 'c', 'd' ]
        r2 = Util.json_keys hash
        assert_equal(r2, ['[n]'])

        hash = { 'array' => ['a', 'b', 'c', 'd'] }
        r3 = Util.json_keys hash
        assert_equal(r3, [ 'array[]', 'array[n]' ])

        hash = {'array' => [ {'key1' => 'value1'}, {'key1' => 'value2'}, {'key2' => 'value3'} ]}
        r4 = Util.json_keys hash
        assert_equal(r4, ['array[]', 'array[n]', 'array[n].key1', 'array[n].key2'])

        hash = {'array' => [ {'key1' => 'value1', 'key2' => 'value2'}, {'key1' => 'value3', 'key3' => 'value4'} ]}
        r5 = Util.json_keys hash
        assert_equal(r5, ['array[]', 'array[n]', 'array[n].key1', 'array[n].key2', 'array[n].key3'])

        hash = { 'a' => { 'b' => { 'c' => [ { x: 1, y: 2}, { z: 1 } ] } } }
        r6 = Util.json_keys hash
        assert_equal(r6, ["a", "a.b", "a.b.c[]", "a.b.c[n]", "a.b.c[n].x", "a.b.c[n].y", "a.b.c[n].z"])

        hash = { 'a' => [] }
        r7 = Util.json_keys hash
        assert_equal(r7, ['a[]'])

        hash = { 'a' => nil }
        r8 = Util.json_keys hash
        assert_equal(r8, ['a'])

        hash = { 'a' => { 'b' => nil } }
        r9 = Util.json_keys hash
        assert_equal(r9, ['a', 'a.b'])

        hash = { a: 1, b: 2, c: 3 }
        r10 = Util.json_keys(hash)
        assert_equal(r10, [ 'a', 'b', 'c' ])

        hash = { a: 1, b: [ {c:9} ], c: 3 }
        r11 = Util.json_keys(hash)
        assert_equal(r11, [ 'a', 'b[]', 'b[n]', 'b[n].c', 'c'])

        hash = { a: 1, b: { c: 3 }, c: 3 }
        r12 = Util.json_keys(hash)
        assert_equal(r12, ["a", "b", "b.c", "c"])

    end

    def test_json_values

        hash = {'a' => { 'b' => { 'c' => { 'd' => 10 }, 'e' => 20 }}}
        r1 = Util.json_values hash
        assert_equal(r1, [{"a.b.c.d"=>10}, {"a.b.e"=>20}])

        hash = [ 'a', 'b', 'c', 'd' ]
        r2 = Util.json_values hash
        assert_equal(r2, [{'[n]'=>"a"}, {'[n]'=>"b"}, {"[n]"=>"c"}, {"[n]"=>"d"}])

        hash = { 'array' => ['a', 'b', 'c', 'd'] }
        r3 = Util.json_values hash
        assert_equal(r3, [{"array[n]"=>"a"}, {"array[n]"=>"b"}, {"array[n]"=>"c"}, {"array[n]"=>"d"}])

        hash = {'array' => [ {'key1' => 'value1'}, {'key1' => 'value2'}, {'key2' => 'value3'} ]}
        r4 = Util.json_values hash
        assert_equal(r4, [{"array[n].key1"=>"value1"}, {"array[n].key1"=>"value2"}, {"array[n].key2"=>"value3"}])

        hash = {'array' => [ {'key1' => 'value1', 'key2' => 'value2'}, {'key1' => 'value3', 'key3' => 'value4'} ]}
        r5 = Util.json_values hash
        assert_equal(r5, [{"array[n].key1"=>"value1"},{"array[n].key2"=>"value2"},{"array[n].key1"=>"value3"},{"array[n].key3"=>"value4"}])

        hash = { 'a' => { 'b' => { 'c' => [ { x: 1, y: 2}, { z: 1 } ] } } }
        r6 = Util.json_values hash
        assert_equal(r6, [{"a.b.c[n].x"=>1}, {"a.b.c[n].y"=>2}, {"a.b.c[n].z"=>1}])

        hash = { 'a' => [] }
        r7 = Util.json_values hash
        assert_equal(r7, [])

        hash = { 'a' => nil }
        r8 = Util.json_values hash
        assert_equal(r8, [{"a"=>nil}])

        hash = { 'a' => { 'b' => nil } }
        r9 = Util.json_values hash
        assert_equal(r9, [{"a.b"=>nil}])

        hash = { a: 1, b: 2, c: 3 }
        r10 = Util.json_values(hash)
        assert_equal(r10, [{"a"=>1}, {"b"=>2}, {"c"=>3}])

        hash = { a: 1, b: [ {c:9} ], c: 3 }
        r11 = Util.json_values(hash)
        assert_equal(r11, [{"a"=>1}, {"b[n].c"=>9}, {"c"=>3}])

        hash = { a: 1, b: { c: 3 }, c: 3 }
        r12 = Util.json_values(hash)
        assert_equal(r12, [{"a"=>1}, {"b.c"=>3}, {"c"=>3}])

    end

end
