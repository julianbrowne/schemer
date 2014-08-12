
dir = File.dirname(__FILE__)

$: << File.expand_path("#{dir}/../lib")
$: << File.expand_path("#{dir}/../test")

require "test/unit"
require "tuff"
require "schema"

class SchemaTest < Test::Unit::TestCase

    def test_init
        r1 = Schema.new().to_s
        r2 = Schema.new({a:1}).to_s
        r3 = Schema.new({"a" => 1}).to_s
        r4 = Schema.new({:a  => 1}).to_s

        assert_equal(r1, '{}')
        assert_equal(r2, '{"a"=>1}')
        assert_equal(r3, '{"a"=>1}')
        assert_equal(r4, '{"a"=>1}')
    end

    def test_retrieve_simple_keys
        bob = Schema.new({'a' => 1})
        assert_equal(bob.retrieve('a'), 1)

        bob = Schema.new({'a' => 1})
        assert_equal(bob.retrieve('b'), nil)

        bob = Schema.new({'a' => { 'b' => { 'c' => { 'd' => 10 }, 'e' => 20 }}})
        assert_equal(bob.retrieve('a').to_s,'{"b"=>{"c"=>{"d"=>10}, "e"=>20}}')
    end

    def test_retrieve_compound_keys
        bob = Schema.new({'a' => { 'b' => 2 }})
        assert_equal(bob.retrieve('a.b'), 2)

        bob = Schema.new({'a' => { 'b' => 2 }})
        assert_equal(bob.retrieve('a.b.c'), nil)

        bob = Schema.new({'a' => { 'b' => { 'c' => { 'd' => 10 }, 'e' => 20 }}})
        assert_equal(bob.retrieve('a.b.c.d'), 10)
    end

    def test_insert_key_existing

        # add value to a simple key that already exists
        s = Schema.new({a:1})
        assert_equal(s.insert_key('a', 10), 10)
        assert_equal(s.to_s,'{"a"=>10}')

        # add value to a deep key that already exists
        s = Schema.new({a:{b:{c:1}}})
        assert_equal(s.insert_key('c', 10, 'a.b'), 10)
        assert_equal(s.to_s,'{"a"=>{"b"=>{"c"=>10}}}')

    end

    def test_insert_key_create

        # add value to a simple key that does not exist
        s = Schema.new
        assert_equal(s.insert_key('a', 10), 10)
        assert_equal(s.to_s,'{"a"=>10}')

        # add value to a deep key that that does not exist
        s = Schema.new
        assert_equal(s.insert_key('c', 10, 'a.b'), 10)
        assert_equal(s.to_s,'{"a"=>{"b"=>{"c"=>10}}}')

    end

    def test_insert
        s = Schema.new
        s.insert('a.b.c', 10)
        assert_equal(s.to_s,'{"a"=>{"b"=>{"c"=>10}}}')

    end

    def test_to_json
        bob = Schema.new({'a' => 1})
        assert_equal(bob.to_json, '{"a":1}')
    end

    def test_has_key
        s = Schema.new({'a'=> 1})
        assert_true(s.has_key?('a'))
        assert_false(s.has_key?('b'))

        s = Schema.new({'a'=> {'b' => {'c' => 10}}})
        assert_true(s.has_key?('a'))
        assert_true(s.has_key?('a.b'))
        assert_true(s.has_key?('a.b.c'))
        assert_false(s.has_key?('b'))
        assert_false(s.has_key?('c'))
    end

    def test_to_s
        bob = Schema.new({'a' => 1})
        assert_equal(bob.to_s, '{"a"=>1}')
    end

    def test_set_key

        # simple set of existing key
        r1 = Schema.new({'a' => 1})
        assert_equal(r1.set_key('a',10), 10)
        assert_equal(r1.to_s, '{"a"=>10}')

        # deep set of existing key
        r2 = Schema.new({'a' => 1, 'b' => 5})
        assert_equal(r2.set_key('b',10), 10)
        assert_equal(r2.to_s, '{"a"=>1, "b"=>10}')

    end

end
