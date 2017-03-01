## Concourse Resource for BOSH Credentials

This resource connects to Ops Manager and obtains the bosh credentials.

### How to use it?

Add the following to your pipeline to set up the resource:

```
resource_types:
- name: bosh-creds
  type: docker-image
  source:
    repository: dlapiduz/bosh-creds-resource
    tag: latest

# ...

resources:
- name: om-bosh-creds
  type: bosh-creds
  source:
    pcf_ert_domain: {{pcf_ert_domain}}
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

Then you will find 4 files:
```
- om-bosh-creds/bosh-ca.pem
- om-bosh-creds/bosh-username
- om-bosh-creds/bosh-pass
- om-bosh-creds/director_ip
```

### Known issues:

Currently the resource only gets credentials once, it doesn't update the credentials if they are changed.
