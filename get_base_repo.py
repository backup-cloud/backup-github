import os

def getRepo(repo_url, login_object):
  '''
  Clones the passed repo
  '''

  path_append = r"base_backup" # Can set this as an arg 
  os.chdir(path_append)

  repo_moddedURL = 'https://' + login_object['username'] + ':' + login_object['password'] + '@github.com/michael-paddle/backup-base.git'
  os.system('git clone '+ repo_moddedURL)

  print('Cloned!')


if __name__ == '__main__':
    getRepo('https://github.com/michael-paddle/backup-base.git', {'username': 'userName', 'password': 'passWord'})