require 'active_support/all'

# Turns a hash from { hi_there: true } to { "hiThere": true } to match engine
# syntax.
def camelcase(hash)
  return unless hash.present?
  hash.deep_transform_keys { |key| key.to_s.camelize(:lower) }
end

# Turns a hash from { "hiThere": true } to { hi_there: true } to match ruby
# like syntax.
def to_ruby_hash(hash)
  return unless hash.present?
  hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
end

def respond(hash)
  puts "RESPONSE: #{hash}"

  camelcase(hash).to_json
end
