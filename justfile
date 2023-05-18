default: add commit push

add:
    git add .

commit:
    cz commit

push:
    git push

bump:
    cz bump
    git push
    git push --tags

publish: bump
    poetry publish --build

shell:
    poetry shell