## Concourse Resource for BOSH Credentials

This resource connects to Ops Manager and obtains BOSH credentials.

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
      params:
        deployment: my_deployment
```

`deployment` param is optional -- it is added to the bosh_source.json for use with [bosh-deployment resource](https://github.com/cloudfoundry/bosh-deployment-resource).

Then you will get the following files:
```
- om-bosh-creds/bosh-ca.pem
- om-bosh-creds/director_ip
- om-bosh-creds/bosh-username
- om-bosh-creds/bosh-pass
- om-bosh-creds/bosh-deployment
- om-bosh-creds/bosh2_commandline_credentials
- om-bosh-creds/opsman_bosh.json
```

The first four files are there for backwards compatibility with the original `bosh-creds-resource` by [Diego Lapiduz](http://github.com/dlapiduz/).

Starting with PCF 1.12 there is a new endpoint which provides credentials to be used by BOSH CLI v2 and `bosh2_commandline_credentials` contains credentials from that endpoint in an easy to consume way - just `source om-bosh-creds/bosh2_commandline_credentials` in your task script and you can perform operations with BOSH CLI (no need to even `bosh login`).

Note: `bosh2_commandline_credentials` returns a different set of credentials and therefore the credentials in `bosh-username` and `bosh-pass` will differ from those in `bosh2_commandline_credentials`.

`opsman_bosh.json` contains the same credentials as `bosh2_commandline_credentials`, plus the deployment name provided as a param but the format of this file is compatible with [bosh-deployment resource](https://github.com/cloudfoundry/bosh-deployment-resource).

`external_bosh.json` contains whatever credentials you provide in the source `external_bosh_address`, `external_bosh_client`, `external_bosh_client_secret` and `external_bosh_ca_cert` fields. The format of this file is compatible with [bosh-deployment resource](https://github.com/cloudfoundry/bosh-deployment-resource). This allows you to easily switch between deploying to OpsManager Director or an arbitrary BOSH Director. All you need to do is provide a pipeline parameter that takes a value of `opsman_bosh` or `external_bosh` and if `external_bosh` is set - all the `external_bosh_*` fields should be provided:
In your resource configuration:
```
- name: pcf-bosh-creds
  type: bosh-creds
  source:
    pcf_opsman_admin_username: ((pcf_opsman_admin_username))
    pcf_opsman_admin_password: ((pcf_opsman_admin_password))
    opsman_url: ((opsman_url))
    external_bosh_address: ((external_bosh_address))
    external_bosh\_client: ((external_bosh_client))
    external_bosh_client_secret: ((external_bosh_client_secret))
    external_bosh_ca_cert: ((external_bosh_ca_cert))
```
In your plan:
```
 - put: bosh-deployment
    params:
      source_file: pcf-bosh-creds/((director_for_deployment)).json
```
And then in your pipeline parameter file either:
```
director_for_deployment: opsman_bosh
```
or:
```
director_for_deployment: external_bosh
external_bosh_address: 35.189.216.223
external_bosh_client: admin
external_bosh_client_secret: 96jkwllh7mq8mdnfg25w
external_bosh_ca_cert: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
```

### Known issues:

Currently the resource only gets credentials once, it doesn't update the credentials if they are changed.
