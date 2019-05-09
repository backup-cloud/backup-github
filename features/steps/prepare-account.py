import boto3
from behave import *

@given(u"I have access to an account for doing backups")
def step_impl(context):
    # Envfile is created when the S3 bucket is set up with credentials
    # that have access to the bucket.
    env_path: str = "./aws_credentials.env"
    load_dotenv(dotenv_path=env_path)

    # testdir_random_id is used for long lived resources like s3 buckets that
    # cannot be created for each test run.

    with open(".anslk_random_testkey") as f:
        testdir_random_id = f.read().rstrip()

    s3 = boto3.resource("s3")
    context.bucket_name = "test-backup-" + testdir_random_id
    assert_that(
        len(context.bucket_name),
        greater_than(len("test-backup-") + 2),
        "bucket name: " + context.bucket_name + " missing random key",
    )
    bucket = s3.Bucket(context.bucket_name)

    context.s3resource = s3
    context.testdir_random_id = testdir_random_id

    # bucket we are going to have backups into
    context.backup_bucket = bucket
    # bucket we are storing data that needs backed up

    context.store_bucket = bucket



def make_new_keypair(gpg_context: gpg.Context, userid: str = None):
    """create a new gpg keypair returning userid, public and private key
    utilitiy function to create a new keypair.  In the case no userid
    is provided we will create a (partly) random one.
    """
    if not userid:
        userid = "backup-" + "".join(
            [random.choice(string.ascii_letters + string.digits) for n in range(10)]
        )

    # ubuntu bionic doesn't ahve key_export_minimial() so we fallback
    # in real life we can assume that the users would export using
    # some graphical tool.

    gpg_context.create_key(
        userid, algorithm="rsa3072", expires_in=31536000, encrypt=True
    )
    try:
        public_key = gpg_context.key_export_minimal(pattern=userid)
    except AttributeError:
        public_key = gpg_context.key_export(pattern=userid)

    private_key = gpg_context.key_export_secret(pattern=userid)

    return userid, public_key, private_key


@given(u"I have a private public key pair")
def step_impl(context) -> None:

    c = gpg.Context(armor=True)
    context.gpg_context = c

    context.gpgdir = TemporaryDirectory()
    c.home_dir = context.gpgdir.name

    userid, public, private = make_new_keypair(c)

    context.gpg_userlist = [userid]
    context.public_key = public
    context.private_key = private

@given(u"the public key from that key pair is stored in an s3 bucket")
def step_impl_1(context) -> None:
    # by contrast random_test_prefix is used for resource local to
    # this test like an S3 path that can be created and destroyed
    # quickly - this will allow parallel testing and independence

    context.random_test_prefix = "".join(
        [random.choice(string.ascii_letters + string.digits) for n in range(10)]
    )

    context.s3_test_path = context.random_test_prefix

    # s3_key = "config/public-keys" + testdir_random_id + "example.com.pub"
    context.s3_key = context.s3_test_path + "/config/public-keys/test-key.pub"

    assert_that(len(context.public_key), greater_than(64), "characters")
    try:
        context.backup_bucket.put_object(Key=context.s3_key, Body=context.public_key)
    except ClientError as e:
        eprint("failed to put public key into s3 bucket: " + context.bucket_name)
        raise e