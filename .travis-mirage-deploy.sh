if [ "$DEPLOY" != "1" ]; then
	echo "Deployment not requested; set DEPLOY=1 to attempt deployment"
elif [ "$TRAVIS_PULL_REQUEST" != "" ] && [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	echo "Deployment will not be performed on a pull request"
elif [ "$TRAVIS_BRANCH" != "master" ]; then
	echo "Deployment will not be performed on pushes to the branch $TRAVIS_BRANCH; try pushing to master"
elif [ "$MIRAGE_BACKEND" != "xen" ]; then
	echo "Deployment strategy for non-Xen targets is unknown; set MIRAGE_BACKEND to xen to attempt a Xen deployment"
	exit 1
elif [ "$XSECRET_default_0" = "" ]; then
	echo "Deployment secret is not known; cannot deploy"
	exit 1
elif [ "$XENIMG" = "" ]; then
	echo "Set XENIMG to the image name to copy (e.g. \"openmirageorg\" or \"mirageio\")"
	exit 1
else
	# OK, let's do this.
	eval `opam config env`
	ssh_config="Host mir-deploy github.com
	Hostname github.com
	StrictHostKeyChecking no
	CheckHostIP no
	UserKnownHostsFile=/dev/null"
	export DEPLOYD="${TRAVIS_REPO_SLUG}/deployment";
	# deployment target expects `mir-${XENIMG}`, so prepend it
	export MIRIMG="mir-${XENIMG}"
	mv ${SRC_DIR}/${XENIMG}.xen ${SRC_DIR}/${MIRIMG}
	# setup ssh
	opam install travis-senv
	mkdir -p ~/.ssh
	travis-senv decrypt > ~/.ssh/id_dsa
	chmod 600 ~/.ssh/id_dsa
	echo "$ssh_config" >> ~/.ssh/config
	# configure git for github
	git config --global user.email 'travis@openmirage.org'
	git config --global user.name 'Travis the Build Bot'
	git config --global push.default simple
	# clone deployment repo
	git clone git@mir-deploy:${TRAVIS_REPO_SLUG}-deployment
	# remove and recreate any existing image for this commit
	mkdir -p $DEPLOYD/xen/$TRAVIS_COMMIT
	cp ${SRC_DIR}/$MIRIMG ${SRC_DIR}/config.ml $DEPLOYD/xen/$TRAVIS_COMMIT
	rm -f $DEPLOYD/xen/$TRAVIS_COMMIT/${MIRIMG}.bz2
	bzip2 -9 $DEPLOYD/xen/$TRAVIS_COMMIT/$MIRIMG
	echo $TRAVIS_COMMIT > $DEPLOYD/xen/latest
	# commit and push changes
	cd $DEPLOYD && \
		git checkout master && \
		git add xen/$TRAVIS_COMMIT xen/latest && \
		git commit -m "adding $TRAVIS_COMMIT for $MIRAGE_BACKEND" && \
		git status && \
		git clean -fdx && \
		git pull --rebase && \
		git push
fi
