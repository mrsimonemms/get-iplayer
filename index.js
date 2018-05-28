/**
 * index
 */

/* Node modules */
const { spawn } = require('child_process');

/* Third-party modules */

/* Files */

function execute(opts) {
  return new Promise((resolve, reject) => {
    const args = [];

    Object.keys(opts)
      .forEach((key) => {
        const value = opts[key];

        if (value.length > 0) {
          value.forEach((v) => {
            args.push(`${key}=${v}`);
          });
        } else {
          args.push(key);
        }
      });

    const getIplayer = spawn('get_iplayer', args);

    getIplayer.stdout.on('data', (data) => {
      process.stdout.write(data);
    });

    getIplayer.stderr.on('data', (data) => {
      process.stderr.write(data);
    });

    getIplayer.on('close', (code) => {
      if (code !== 0) {
        return reject();
      }

      return resolve();
    });
  });
}

function run(args) {
  /* Check if we have any PIDs set */
  if (Object.prototype.hasOwnProperty.call(args, '--pid')) {
    const pids = args['--pid']
      .reduce((result, item) => {
        result.push(...item.split(','));

        return result;
      }, []);

    delete args['--pid']; // eslint-disable-line no-param-reassign

    return pids.reduce((thenable, pid) => thenable
      .then(() => {
        Object.defineProperty(args, '--pid', {
          enumerable: true,
          value: [
            pid.trim(),
          ],
        });

        return execute(args);
      }), Promise.resolve());
  }

  return execute(args);
}

const args = process.argv
  .reduce((result, item, id) => {
    if (id > 1) {
      const [key, value] = item.split('=');

      if (!Object.prototype.hasOwnProperty.call(result, key)) {
        Object.defineProperty(result, key, {
          enumerable: true,
          value: [],
        });
      }

      if (value !== undefined) {
        result[key].push(value);
      }
    }

    return result;
  }, {});

args['--output'] = [
  process.env.OUTPUT_DIR,
];

Promise.resolve()
  .then(() => run(args))
  .then(() => {
    process.exit();
  })
  .catch(() => {
    process.exit(1);
  });
