import os
import pytest

def test_gitops_directories_exist():
    clusters_dir = os.path.join(os.path.dirname(__file__), '..', 'clusters')
    manifests_dir = os.path.join(os.path.dirname(__file__), '..', 'manifests')
    assert os.path.exists(clusters_dir), "Clusters directory should exist"
    assert os.path.exists(manifests_dir), "Manifests directory should exist"
