import json
import sys
from backup_cloud import BackupContext

def main_function(filename):

    context.ssm_path = "/testing/backup_context/" + context.random_test_prefix
    context.file_in = filename
    context.file_out = filename + ".gpg"
    with open(context.file_in, "wb") as data_file:
        data_file.write(context.data)

    bc = BackupContext(ssm_path=context.ssm_path)
    context.backup_context = bc

    context.backup_context.run(["fixtures/encrypt_file.sh"])

    with open(context.file_out, "rb") as data_file:
        context.encrypted_file_contents = data_file.read()

if __name__ == "__main__":
    main_function(sys.argv[1])
    