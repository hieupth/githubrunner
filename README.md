# Github Runner
A self-hosted GitHub Actions runner image, built on [`myoung34/github-runner`](https://github.com/myoung34/docker-github-actions-runner) with Miniforge for reproducible conda-based jobs.

## Tags
| Tag | Meaning |
| --- | --- |
| `latest` | Newest runner release, built on the runner image's default Ubuntu |
| `resolute` | Newest runner release, built on Ubuntu 26.04 LTS |
| `noble` | Newest runner release, built on Ubuntu 24.04 LTS |

Platforms: `linux/amd64`, `linux/arm64`.

## Usage
Runners register exactly like [`myoung34/github-runner`](https://github.com/myoung34/docker-github-actions-runner) — see [the wiki](https://github.com/myoung34/docker-github-actions-runner/wiki/Usage) for the full guide. `conda` (Miniforge) is on `PATH`.

```bash
docker run -d --restart=always --name github-runner \
    -e ACCESS_TOKEN="INSERT TOKEN HERE" \
    -e RUNNER_SCOPE="org" \
    -e ORG_NAME="YOUR ORG NAME" \
    -e LABELS="some-label-1,some-label-2" \
    -e RUNNER_GROUP="DEFAULT_GROUP_NAME" \
    hieupth/githubrunner:latest
```

## Environment Variables
| Environment Variable | Description |
| --- | --- |
| `RUN_AS_ROOT` | Boolean to run as root. If `true`: will run as root. If `True` and the user is overridden it will error. If any other value it will run as the `runner` user and allow an optional override. Default is `true` |
| `RUNNER_NAME` | The name of the runner to use. Supersedes (overrides) `RUNNER_NAME_PREFIX` |
| `RUNNER_NAME_PREFIX` | A prefix for runner name (See `RANDOM_RUNNER_SUFFIX` for how the full name is generated). Note: will be overridden by `RUNNER_NAME` if provided. Defaults to `github-runner` |
| `RANDOM_RUNNER_SUFFIX` | Boolean to use a randomized runner name suffix (preceded by `RUNNER_NAME_PREFIX`). Will use a 13 character random string by default. If set to a value other than true and `RUNNER_NAME_PREFIX` is set to an empty string, it will attempt to use the contents of `/etc/hostname` or fall back to a random string if the file does not exist or is empty. Note: will be overridden by `RUNNER_NAME` if provided. Defaults to `true`. |
| `ACCESS_TOKEN` | A [github PAT](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) to use to generate `RUNNER_TOKEN` dynamically at container start. Not using this requires a valid `RUNNER_TOKEN` |
| `APP_ID` | The github application ID. Must be paired with `APP_PRIVATE_KEY` and should not be used with `ACCESS_TOKEN` or `RUNNER_TOKEN` |
| `APP_PRIVATE_KEY` | The github application private key. Must be paired with `APP_ID` and should not be used with `ACCESS_TOKEN` or `RUNNER_TOKEN` |
| `APP_LOGIN` | The github application login id. Can be paired with `APP_ID` and `APP_PRIVATE_KEY` if default value extracted from `REPO_URL` or `ORG_NAME` is not correct. Note that no default is present when `RUNNER_SCOPE` is 'enterprise'. |
| `RUNNER_SCOPE` | The scope the runner will be registered on. Valid values are `repo`, `org` and `ent`. For 'org' and 'enterprise', `ACCESS_TOKEN` is required and `REPO_URL` is unnecessary. If 'org', requires `ORG_NAME`; if 'ent', requires `ENTERPRISE_NAME`. Default is 'repo'. |
| `ORG_NAME` | The organization name for the runner to register under. Requires `RUNNER_SCOPE` to be 'org'. No default value. |
| `ENTERPRISE_NAME` | The enterprise name for the runner to register under. Requires `RUNNER_SCOPE` to be 'enterprise'. No default value. |
| `LABELS` | A comma separated string to indicate the labels. Default is 'default' |
| `REPO_URL` | If using a non-organization runner this is the full repository url to register under such as 'https://github.com/myoung34/repo' |
| `RUNNER_TOKEN` | If not using a PAT for `ACCESS_TOKEN` this will be the runner token provided by the Add Runner UI (a manual process). Note: This token is short lived and will change frequently. `ACCESS_TOKEN` is likely preferred. |
| `RUNNER_WORKDIR` | The working directory for the runner. Runners on the same host should not share this directory. Default is '/_work'. This must match the source path for the bind-mounted volume at RUNNER_WORKDIR, in order for container actions to access files. |
| `RUNNER_WORKDIR_ROOT` | Optional. Base directory used to build the default per-runner workdir when `RUNNER_WORKDIR` is not set: each runner gets `<RUNNER_WORKDIR_ROOT>/<runner name>`, so replicas sharing a mount (e.g. a common build cache) do not collide. Defaults to `/_work`. Ignored when `RUNNER_WORKDIR` is set explicitly. |
| `RUNNER_GROUP` | Name of the runner group to add this runner to (defaults to the default runner group) |
| `GITHUB_HOST` | Optional URL of the Github Enterprise server e.g github.mycompany.com. Defaults to `github.com`. |
| `GITHUB_API_HOST` | Optional API host to use for token generation. Useful when the API host differs from `GITHUB_HOST`, e.g. `api.mycompany.ghe.com` for GitHub Enterprise Cloud with data residency. |
| `GITHUB_API_PATH` | Optional API path to use for token generation. Defaults to `/api/v3` for non-`github.com` hosts. Set to `/` when the API host does not use a path. |
| `DISABLE_AUTOMATIC_DEREGISTRATION` | Optional flag to disable signal catching for deregistration. Default is `false`. Any value other than exactly `false` is considered `true`. See [here](https://github.com/myoung34/docker-github-actions-runner/issues/94) |
| `CONFIGURED_ACTIONS_RUNNER_FILES_DIR` | Path to use for runner data. It allows avoiding reregistration each the start of the runner. No default value. |
| `EPHEMERAL` | Optional flag to configure runner with [`--ephemeral` option](https://docs.github.com/en/actions/hosting-your-own-runners/autoscaling-with-self-hosted-runners#using-ephemeral-runners-for-autoscaling). Ephemeral runners are suitable for autoscaling. |
| `DISABLE_AUTO_UPDATE` | Optional environment variable to [disable auto updates](https://github.blog/changelog/2022-02-01-github-actions-self-hosted-runners-can-now-disable-automatic-updates/). Auto updates are enabled by default to preserve past behavior. Any value is considered truthy and will disable them. |
| `START_DOCKER_SERVICE` | Optional flag which automatically starts the docker service if set to `true`. Useful when using [sysbox](https://github.com/nestybox/sysbox). Defaults to `false`. |
| `NO_DEFAULT_LABELS` | Optional environment variable to disable adding the default self-hosted, platform, and architecture labels to the runner. Any value is considered truthy and will disable them. |
| `DEBUG_ONLY` | Optional boolean to print debug output but not run any actual registration or runner commands. Used in CI and testing. Default: false |
| `DEBUG_OUTPUT` | Optional boolean to print additional debug output. Default: false |
| `UNSET_CONFIG_VARS` | Optional flag to unset all configuration environment variables after runner setup but before starting the runner. This prevents these variables from leaking into the workflow environment. Set to 'true' to enable. Defaults to 'false' for backward compatibility. |

## Extra packages
Inject additional apt packages at build time without touching the dockerfile:
```bash
docker build --build-arg PACKAGES="jq htop" .
```
Or set the `packages` input when dispatching the Build workflow.

## License
[Apache License 2.0](LICENSE).<br>
Copyright &copy; 2026 [Hieu Pham](https://github.com/hieupth). All rights reserved.
