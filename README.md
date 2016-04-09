# x3dpython

```
git clone https://github.com/coderextreme/x3dpython/
cd x3dpython
```
You may need to edit mysite/settings.py for STATIC_ROOT (set to your folder on you webroot
```
./manage.py collectstatic
./manage.py runserver
```
Then go to http://localhost:8000/static/index.html

Modify files under static/

Then rerun

```
./manage.py collectstatic
```
