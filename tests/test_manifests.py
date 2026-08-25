import os
import pytest

def test_gitops_directories_exist():
    apps_dir = os.path.join(os.path.dirname(__file__), '..', 'apps')
    assert os.path.exists(apps_dir), "Apps directory should exist"
