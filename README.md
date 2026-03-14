# lex-cognitive-reserve

A LegionIO cognitive architecture extension that models cognitive reserve — the brain's ability to maintain function despite damage or load by activating backup pathways and compensatory routing.

## What It Does

Tracks a network of **cognitive pathways**, each with:

- A functional role and domain
- A current capacity (0.0 to 1.0)
- Links to backup pathways for compensation

When a pathway is damaged below the degraded threshold (0.5), backup pathways activate to partially compensate. The overall reserve level is computed as the mean effective capacity across all pathways.

This models phenomena like expertise-based resilience: an agent with more redundant pathways can sustain higher cognitive output under stress.

## Usage

```ruby
require 'lex-cognitive-reserve'

client = Legion::Extensions::CognitiveReserve::Client.new

# Add pathways
client.add_cognitive_pathway(function: 'language_comprehension', domain: :language)
# => { success: true, pathway_id: :path_1, capacity: 1.0 }

client.add_cognitive_pathway(function: 'language_backup', domain: :language, capacity: 0.8)
# => { success: true, pathway_id: :path_2, capacity: 0.8 }

# Link backup
client.link_backup_pathway(primary_id: :path_1, backup_id: :path_2)

# Simulate damage
client.damage_cognitive_pathway(pathway_id: :path_1, amount: 0.6)
# => { capacity: 0.4, state: :compensating, effective_capacity: 0.64 }

# Check reserve
client.cognitive_reserve_assessment
# => { overall_reserve: 0.72, reserve_label: :adequate, ... }

# Periodic recovery
client.update_cognitive_reserve
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
