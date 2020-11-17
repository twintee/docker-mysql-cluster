# dk_alp
private docker-compose

require
- ubuntu :16.*, 18.*

include
- db container
    - mysql
- cache container
    - redis(include manager/slave node)
- application container
    - nginx
    - php7.4(with composer)

git repository not include env and shells in local settings.
