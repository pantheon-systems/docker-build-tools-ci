---
contract_version: 2
kind: tool                          # public CI image; customers' and Pantheon repos' CI pull it by floating tag
service: build-tools-ci
lifecycle: deprecated               # final release 2026-06-09 (#134, DEVX-7174); README says no more updates

trigger: merge-to-main              # a push to 9.x (default branch) rebuilds and pushes the 9.x-php* tags; a push to 8.x does the same for 8.x-php*
merged_implies_deployed: true       # tags are floating: the next CI pull anywhere gets the new image
other_paths_to_prod:
  - "push to the 8.x branch builds and pushes 8.x-php7.4 … 8.x-php8.3 (8.x's own .github/workflows/build_and_push.yml) — the tags most consumers use"
  - "re-running an old build_and_push run republishes that commit's Dockerfile, but with whatever upstream packages resolve TODAY (the build isn't reproducible)"

pipeline:
  system: github-actions
  workflow: ".github/workflows/build_and_push.yml"   # 'Docker Build Tools Image (Build and Push)', on push to 9.x; build_only.yml runs on other branches
  jobs_in_order: ["docker-build (matrix PHP 8.2, 8.3, 8.4; parallel)"]
  typical_minutes: 5                # inferred from run on 2026-06-09 (1c39fd0); the 2026-11-09 run failed after 3.5 min
  minutes_by_change: {}
  watch: "Actions workflow 'Docker Build Tools Image (Build and Push)' on 9.x; all three matrix jobs green"
  concurrency_group: null
  cancel_in_progress: false         # but matrix fail-fast is on: one PHP version failing cancels the others
  blocked_by_waiting_run: null
  approval_gate: null
  current_state: "red: the 2026-11-09 run (441d98b, action SHA pins) failed building 8.4 at `composer require squizlabs/php_codesniffer:^2.7`; 8.2/8.3 were cancelled. Nothing was pushed"   # verified

repo_properties:
  observed_at: 2026-11-10
  trust_level: TL3
  ccb_status: in-ccb
  owner: developer-experience
  repo_type: tool

gating_checks:                      # for 9.x (default branch)
  required: ["Wiz IaC Scanner", "Wiz Vulnerability Scanner", "Wiz Data Scanner"]   # org TL3
  approvals: {required: 1, code_owner: true, last_push_approval: false, strict_up_to_date: true, merge_queue: false}   # org TL3 + a repo pull_request rule
  run_but_not_required: ["Build and push <php> Docker image"]
  conditional: []
  code_owners: "@pantheon-systems/developer-experience"

environments: []

artifact:
  image: ["quay.io/pantheon-public/build-tools-ci", "docker.io/pantheonpublic/build-tools-ci"]   # both pushed by the same job
  tag_scheme: fixed                 # <branch>-php<version>, e.g. 9.x-php8.4; no per-build tags
  tag_mutable: true
  retention: "Quay keeps a tag's previous manifest for 14 days (tag_expiration_s 1209600); Docker Hub keeps no tag history [inferred]"
  version_signal: digest
  current:                          # verified 2026-11-10 via the public Quay API
    "9.x-php8.2": "sha256:d357e5f8fac3833e7a029e923cff88a977a22bb2db0636d49480bb44594c2da6 (2026-06-09)"
    "9.x-php8.3": "sha256:8b298072d8f40908a4fc29bd235ba96602531cda907625ec87ae5d0b4d83b8de (2026-06-09)"
    "9.x-php8.4": "sha256:c0a76ece647c4f594d122311bea26e30466458ae06ba9b01238d5d4c49a5f5ec (2026-06-09; Docker Hub has the same digest)"
    "8.x-php*": "last pushed 2024-09-23"

release:
  mechanism: "merge to 9.x (or push to 8.x); CI builds and pushes the floating tags to Quay and Docker Hub"
  never: "push to 8.x casually: it republishes the images most consumers pin"

consumers:                          # all pull a floating tag at CI run time
  - repo: "customer sites' CI built from Terminus Build Tools templates (public image)"
  - repo: tbt-ci-templates          # d7/d8/d9/wp templates for CircleCI, GitHub Actions, GitLab, Bitbucket
    pin: "build-tools-ci:8.x-php8.1"
  - repo: circleci-orb
    pin: "build-tools-ci:8.x-php8.1"
  - repo: cu-push-to-pantheon
    pin: "build-tools-ci:8.x-php8.1 (workflows)"
  - repo: "solr-power, pantheon-wordpress-upstream-tests, decoupled-kit-nightly-canaries"
    pin: "build-tools-ci:8.x-php7.4 (GitHub Actions)"
  - repo: documentation             # release note 2026-06-15 announcing the deprecation

deployed_when:
  - "build_and_push run green for every matrix PHP version"
  - "Quay `<branch>-php<v>` tags show a new manifest digest with last_modified after the run"

health:
  soak_minutes: null                # delegated to consumers' CI
  baseline: null
  checks:
    - name: tag digests moved
      kind: command
      run: "for t in 9.x-php8.2 9.x-php8.3 9.x-php8.4; do curl -s \"https://quay.io/api/v1/repository/pantheon-public/build-tools-ci/tag/?specificTag=$t&onlyActiveTags=true\" | jq -r --arg t $t '.tags[0]|[$t,.last_modified,.manifest_digest]|@tsv'; done"
      healthy: "every tag has a new digest from this run"
    - name: consumer CI
      kind: delegate
      run: "the next runs of a consumer that uses the changed tag (e.g. solr-power lint-test for 8.x-php7.4)"
      healthy: "no new failures in steps that use the image"
  known_baseline_errors: ["9.x build is red since 2026-11-09 (see pipeline.current_state)"]
  dashboards: []
  alerts: []

rollback:
  options:
    - when: "within 14 days of a bad push"
      kind: redeploy-previous
      steps: "in Quay, restore the tag to its previous manifest (tag history), and push the same digest to Docker Hub. TODO(owner): who has write on the pantheon-public Quay org and the pantheonpublic Docker Hub org"
      time_to_rollback_minutes: 15  # inferred
    - when: otherwise
      kind: revert-and-merge
      steps: "revert on the branch and let CI rebuild. Not reliable: the build resolves upstream packages at build time and currently fails (see pipeline.current_state), so the rebuilt image won't match the old one"
      time_to_rollback_minutes: null
  not_restored: ["Docker Hub has no tag history, so its old digest must be captured before the push"]
  one_way_changes: []
  currently_blocked: "revert-and-rebuild is blocked: the 9.x build has failed since 2026-11-09"
  last_exercised: null
  capture_before_merge: "the Quay command under health.checks (record each tag's manifest_digest), plus `docker buildx imagetools inspect docker.io/pantheonpublic/build-tools-ci:<tag>` for Docker Hub"
  who_can: ["TODO(owner): holders of Quay pantheon-public / Docker Hub pantheonpublic write access (the CI uses repo secrets QUAY_* and DOCKERHUB_*)"]
  verify: "the tag's digest equals the captured one in both registries"

escalation:
  slack: "#ask-hosting"
  owner_team: developer-experience
  paged: false
  known_security_issue: "TODO(owner): ticket"

preflight:
  - "gh auth status"
  - "outbound HTTPS to quay.io and hub.docker.com (public reads, no auth)"

automation_blockers:
  - blocker: "floating tags: every merge to 9.x (or push to 8.x) is an immediate, unreviewable change for every consumer, with no per-build tag to roll back to"
    clears_when: "CI also pushes an immutable per-commit tag, and consumers that matter pin it"
  - blocker: "the build isn't reproducible and is currently red, so a revert can't restore an old image"
    clears_when: "the Dockerfile pins its tool versions and 9.x builds green, or the project is archived (it's deprecated)"
  - blocker: "rollback by digest needs registry write access nobody has written down"
    clears_when: "TODO(owner) names the holders"

verified:
  at: null
  by: null
  change: null
  running_digest: null
---

# Deployment

`docker-build-tools-ci` is the Dockerfile for the public CI image `quay.io/pantheon-public/build-tools-ci` (also `docker.io/pantheonpublic/build-tools-ci`), used by Terminus Build Tools CI templates and several Pantheon repos' CI. **It is deprecated**: the final release was 2026-06-09 ([#134](https://github.com/pantheon-systems/docker-build-tools-ci/pull/134), DEVX-7174). Merges still publish, though: **a push to `9.x` (the default branch) rebuilds and pushes the floating `9.x-php*` tags**, and consumers get it on their next CI run.

## How a change reaches production

- **`9.x`** (default branch, Terminus 4): merge a PR (one code-owner approval, org TL3). `build_and_push.yml` builds PHP 8.2, 8.3 and 8.4 in parallel and pushes `9.x-php<v>` to Quay and Docker Hub. About 5 minutes [inferred]. Fail-fast is on: one failing PHP version cancels the others.
- **`8.x`** (Terminus 3): a push to the `8.x` branch runs that branch's own `build_and_push.yml` and pushes `8.x-php7.4` … `8.x-php8.3`. **These are the tags most consumers use** (`tbt-ci-templates`, `circleci-orb`, `cu-push-to-pantheon` on `8.x-php8.1`; `solr-power`, `pantheon-wordpress-upstream-tests`, `decoupled-kit-nightly-canaries` on `8.x-php7.4`). Last pushed 2024-09-23.
- Other branches run `build_only.yml` (no push). `7.x` and lower are unsupported.

**Current state:** the 2026-11-09 `9.x` run ([42629989831](https://github.com/pantheon-systems/docker-build-tools-ci/actions/runs/42629989831), the action SHA-pin commit) failed building PHP 8.4 at `composer require squizlabs/php_codesniffer:^2.7`, so nothing was pushed; the `9.x` tags are still the 2026-06-09 build. The build resolves upstream packages at build time, so it isn't reproducible.

## How to confirm it deployed

```bash
for t in 9.x-php8.2 9.x-php8.3 9.x-php8.4; do
  curl -s "https://quay.io/api/v1/repository/pantheon-public/build-tools-ci/tag/?specificTag=$t&onlyActiveTags=true" \
    | jq -r --arg t $t '.tags[0]|[$t,.last_modified,.manifest_digest]|@tsv'
done
```

Each tag should show a new digest with `last_modified` after the run. On 2026-11-10 they were the 2026-06-09 digests (`9.x-php8.4` = `sha256:c0a76ece…`, same on Docker Hub).

## How to confirm it's healthy

Delegated to consumers: the next CI runs that use the changed tag should show no new failures in image-dependent steps. No dashboards or alerts exist.

## Rollback

Capture each tag's digest before merging (the command above, and `docker buildx imagetools inspect docker.io/pantheonpublic/build-tools-ci:<tag>` for Docker Hub, which keeps no tag history).

1. **Within 14 days:** point each tag back at its captured digest: Quay keeps a tag's previous manifest for 14 days; push the same digest to Docker Hub. TODO(owner): who has write on the Quay `pantheon-public` and Docker Hub `pantheonpublic` orgs (CI uses the `QUAY_*` and `DOCKERHUB_*` repo secrets).
2. **Otherwise:** revert and let CI rebuild. This doesn't restore the old image (the build isn't reproducible) and is currently blocked because the `9.x` build fails.

Rollback has never been exercised. Verify that each tag's digest equals the captured one in both registries.

## Escalation

`#ask-hosting` (developer-experience). Nobody is paged.

## Suggested pipeline changes

- Decide the end state of the deprecation: archive the repo (which stops publishing) or fix the `9.x` build.
- If it keeps publishing: push an immutable per-commit tag alongside the floating one, and pin tool versions in the Dockerfile.
- Known security issue: TODO(owner): ticket.
