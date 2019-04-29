import boto3
from behave import *

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def call_ansible_step(step_name, playbook="test-system.yml", extra_vars=None):
    """call_ansible_step - run a step by running a matching ansible tag"""

    proc_res = subprocess.run(args=["ansible-playbook", "--list-tags", playbook],
                              capture_output=True)
    if proc_res.returncode > 0:
        eprint("Ansible STDOUT:\n", proc_res.stdout, "Ansible STDERR:\n", proc_res.stderr)
        raise Exception("ansible failed while listing tags")

    lines = [x.lstrip() for x in proc_res.stdout.split(b"\n")]
    steps_lists = [x[10:].rstrip(b"]").lstrip(b"[ ").split(b",")
                   for x in lines if x.startswith(b"TASK TAGS:")]
    steps = [x.lstrip() for y in steps_lists for x in y]
    eprint(b"\n".join([bytes(x) for x in steps]))
    if bytes(step_name, 'latin-1') not in steps:
        raise Exception("Ansible playbook: `" + playbook + "' missing tag: `" + step_name + "'")

    eprint("calling ansible with: ", step_name)
    ansible_args = ["ansible-playbook", "-vvv", "--tags", step_name, playbook]
    if extra_vars is not None:
        ansible_args.extend(["--extra-vars", extra_vars])
    proc_res = subprocess.run(args=ansible_args, capture_output=True)
    eprint("Ansible STDOUT:\n", proc_res.stdout, "Ansible STDERR:\n", proc_res.stderr)
    if proc_res.returncode > 0:
        raise Exception("ansible failed")   

@given(u'that I have configured a lambda in AWS')
def step_impl(context):
    
    raise NotImplementedError(u'STEP: Given that I have configured a lambda in AWS')

@given(u'that I have the bash script to perform the backup')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have the bash script to perform the backup')

@given(u'that I have created a fargate task')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have created a fargate task')

@given(u'that I have an S3 backup bucket where I have write access')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have an S3 backup bucket where I have write access')

@given(u'that I have a file in S3 to backup')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have a file in S3 to backup')

@given(u'that I have an ECS role which gives me all needed permissions')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have an ECS role which gives me all needed permissions')

@when(u'I run my backup container giving the base path')
def step_impl(context):
    raise NotImplementedError(u'STEP: When I run my backup container giving the base path')


@then(u'a backup should be created in the S3 destination bucket')
def step_impl(context):
    raise NotImplementedError(u'STEP: Given that I have a file in S3 to backup')


@then(u'that backup should contain my data')
def step_impl(context):
    raise NotImplementedError(u'STEP: Then that backup should contain my data')

@when(u'I run a backup on the database using the public key')
def step_impl(context):
    call_ansible_step("given that I have configured environment definitions",
                      playbook="test-backup.yml")
    keystr = context.public_key.decode('utf-8').replace('\n', '\\n')
    run_fargate_with_envfile('backup-task-environment', image="paddlehq/mysql-backup-s3",
                             call_env={"PUBLIC_KEY": keystr})


