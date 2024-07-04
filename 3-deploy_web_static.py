#!/usr/bin/python3
from fabric.api import env, local, put, run
from os.path import exists
import time

env.hosts = ['<IP web-01>', '<IP web-02>']
env.user = 'ubuntu'
env.key_filename = 'my_ssh_private_key'

def do_pack():
    """Generate a .tgz archive from the contents of the web_static folder."""
    try:
        local("mkdir -p versions")
        timestamp = time.strftime("%Y%m%d%H%M%S")
        archive_path = "versions/web_static_{}.tgz".format(timestamp)
        local("tar -cvzf {} web_static".format(archive_path))
        return archive_path
    except:
        return None

def do_deploy(archive_path):
    """Distribute an archive to the web servers."""
    if not exists(archive_path):
        return False
    try:
        # Upload the archive to the /tmp/ directory of the web server
        put(archive_path, "/tmp/")
        
        # Extract the filename without extension
        filename = archive_path.split("/")[-1]
        no_ext = filename.split(".")[0]
        
        # Create the release directory
        release_dir = "/data/web_static/releases/{}".format(no_ext)
        run("mkdir -p {}".format(release_dir))
        
        # Uncompress the archive to the folder
        run("tar -xzf /tmp/{} -C {}".format(filename, release_dir))
        
        # Remove the archive from the web server
        run("rm /tmp/{}".format(filename))
        
        # Move the content from web_static to the release folder
        run("mv {}/web_static/* {}".format(release_dir, release_dir))
        
        # Remove the now empty web_static folder
        run("rm -rf {}/web_static".format(release_dir))
        
        # Delete the current symbolic link
        run("rm -rf /data/web_static/current")
        
        # Create a new symbolic link
        run("ln -s {} /data/web_static/current".format(release_dir))
        
        return True
    except:
        return False

def deploy():
    """Create and distribute an archive to the web servers."""
    archive_path = do_pack()
    if archive_path is None:
        return False
    return do_deploy(archive_path)
