## Concourse Resource for BOSH Credentials

This resource connects to Ops Manager and obtains the bosh credentials.

### How to use it?

Add the following to your pipeline to set up the resource:

```
resource_types:
- name: bosh-creds
  type: docker-image
  source:
    repository: mkuratczyk/bosh-creds-resource
    tag: latest

# ...

resources:
- name: om-bosh-creds
  type: bosh-creds
  source:
    pcf_opsman_admin_username: {{pcf_opsman_admin_username}}
    pcf_opsman_admin_password: {{pcf_opsman_admin_password}}
    opsman_url: {{opsman_url}}
```

Then add the resource to your job:

```
- name: job-name
  plan:
  - aggregate:
    # ...
    - get: om-bosh-creds
```

Then you will find 5 files:
```
- om-bosh-creds/bosh-ca.pem
- om-bosh-creds/director_ip
- om-bosh-creds/bosh-username
- om-bosh-creds/bosh-pass
- om-bosh-creds/bosh2_commandline_credentials
```

The first four files are there for backwards compatibility. Starting with PCF 1.12 there is a new endpoint which provides credentials to be used by BOSH CLI v2.
Just `source om-bosh-creds/bosh2_commandline_credentials` in your task script and you can perform operations with BOSH CLI (no need to run `bosh login`).

### Known issues:

Currently the resource only gets credentials once, it doesn't update the credentials if they are changed.
