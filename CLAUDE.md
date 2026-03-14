# lex-cognitive-reserve

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-reserve`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveReserve`

## Purpose

Models cognitive reserve as a network of functional pathways. Inspired by neuroscience research showing that individuals with more cognitive reserve can sustain function despite damage, this extension tracks pathway capacities, enables backup/compensation routing, and computes overall reserve levels. It supports graceful degradation and resilience modeling in the agentic architecture.

## Gem Info

- **Gemspec**: `lex-cognitive-reserve.gemspec`
- **Require**: `lex-cognitive-reserve`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-reserve

## File Structure

```
lib/legion/extensions/cognitive_reserve/
  version.rb
  helpers/
    constants.rb        # Capacity bounds, thresholds, reserve labels, pathway states
    pathway.rb          # Pathway class — a single cognitive functional pathway
    reserve_engine.rb   # ReserveEngine — manages all pathways and history
  runners/
    cognitive_reserve.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_PATHWAYS` | 100 | Hard cap on tracked pathways |
| `MAX_COMPENSATIONS` | 200 | Max compensations tracked |
| `MAX_HISTORY` | 300 | Event history ring size |
| `DEFAULT_CAPACITY` | 1.0 | Full capacity on creation |
| `DEGRADED_THRESHOLD` | 0.5 | Below this = degraded state |
| `FAILED_THRESHOLD` | 0.1 | Below this = failed state |
| `COMPENSATION_EFFICIENCY` | 0.7 | How much of deficit a backup recovers |
| `RECOVERY_RATE` | 0.02 | Capacity gain per `recover` tick |
| `COMPENSATION_DECAY` | 0.01 | Decay rate for unused compensatory pathways |

Reserve level labels keyed by ratio:
- `0.8+` = `:robust`, `0.6..0.8` = `:adequate`, `0.4..0.6` = `:reduced`, `0.2..0.4` = `:vulnerable`, `<0.2` = `:critical`

## Key Classes

### `Helpers::Pathway`

Represents one functional cognitive pathway with capacity tracking.

- States: `:healthy`, `:degraded`, `:compensating`, `:failed`
- `damage(amount:)` — reduces capacity; auto-triggers compensation check by engine
- `recover(amount: RECOVERY_RATE)` — increments capacity
- `add_backup(pathway_id:)` / `remove_backup(pathway_id:)` — manage redundancy links
- `compensate!` — increments compensation counter (called by engine)
- `effective_capacity(backup_capacities: [])` — computes capacity accounting for backup compensation
- `redundancy` — count of backup pathway IDs

### `Helpers::ReserveEngine`

Manages all pathways and computes aggregate metrics.

- `add_pathway(function:, domain:, capacity:)` — creates and registers a Pathway
- `link_backup(primary_id:, backup_id:)` — creates a redundancy link
- `damage_pathway(pathway_id:, amount:)` — damages and activates compensation if degraded
- `recover_pathway(pathway_id:, amount:)` — restores capacity
- `effective_capacity(pathway_id:)` — looks up backup capacities and delegates
- `overall_reserve` — mean effective capacity across all pathways
- `reserve_label` — label from `RESERVE_LABELS` for current reserve ratio
- `domain_reserve(domain:)` — reserve calculation scoped to a domain
- `most_vulnerable(limit:)` — sorted ascending by capacity
- `most_redundant(limit:)` — sorted descending by backup count
- `recover_all` — runs `recover` on every non-failed pathway

## Runners

Module: `Legion::Extensions::CognitiveReserve::Runners::CognitiveReserve`

| Runner | Key Args | Returns |
|---|---|---|
| `add_cognitive_pathway` | `function:`, `domain:`, `capacity:` | `{ success:, pathway_id:, capacity: }` |
| `link_backup_pathway` | `primary_id:`, `backup_id:` | `{ success:, backup_count: }` |
| `damage_cognitive_pathway` | `pathway_id:`, `amount:` | `{ capacity:, state:, effective_capacity: }` |
| `recover_cognitive_pathway` | `pathway_id:`, `amount:` | `{ capacity:, state: }` |
| `cognitive_reserve_assessment` | — | `{ overall_reserve:, reserve_label:, most_vulnerable:, degraded:, failed: }` |
| `domain_cognitive_reserve` | `domain:` | `{ reserve:, pathway_count: }` |
| `most_redundant_pathways` | — | `{ pathways:, count: }` |
| `update_cognitive_reserve` | — | runs `recover_all`, returns stats |
| `cognitive_reserve_stats` | — | summary from `engine.to_h` |

## Integration Points

- No actors defined; periodic recovery can be triggered by external scheduler
- Designed to be called from `lex-tick` phase handlers to model resilience capacity
- Can be paired with `lex-cognitive-scaffolding` (skill competence) for a fuller capability model
- All state is in-memory per `ReserveEngine` instance

## Development Notes

- Pathway IDs are sequential symbols (`:path_1`, `:path_2`, ...) assigned by the engine
- `effective_capacity` is only improved by backups when primary is below `DEGRADED_THRESHOLD`
- Compensation activates only the first healthy backup found (not all backups simultaneously)
- History is a ring buffer capped at `MAX_HISTORY`
- `recover_all` skips `failed?` pathways (capacity <= 0.1); they require explicit recovery with a larger amount
