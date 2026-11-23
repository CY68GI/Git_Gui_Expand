# Spec Delta

## ADDED Requirements

### Requirement: Commit identity is ready

The system MUST verify an effective Git author and committer identity before a
commit is planned and again immediately before execution.

#### Scenario: Identity is missing when planning a commit

- **WHEN** the user requests a commit but Git cannot resolve `user.name` or
  `user.email`
- **THEN** the system refuses to add the commit to the plan and explains how to
  configure a repository-local or global Git identity

#### Scenario: Identity changes after the commit is planned

- **WHEN** the effective author or committer identity becomes invalid before the
  queued commit runs
- **THEN** the commit step fails before staging or creating a commit and the
  repository remains unchanged

#### Scenario: Valid identity is available

- **WHEN** effective author and committer identity are available at planning and
  execution time
- **THEN** the commit proceeds through the existing preview and confirmation
  workflow
