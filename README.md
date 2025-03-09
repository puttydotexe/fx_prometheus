![fx_prometheus](https://i.imgur.com/NHJRSN3.png)

# fxPrometheus
**Export critical performance metrics with ease in pure Lua!</br>**
This was written in preparation of FiveM commits [#3221](https://github.com/citizenfx/fivem/pull/3221) and [#3162](https://github.com/citizenfx/fivem/pull/3162).

> [!CAUTION]
> This project is still a work in progress and not recommended for production use just yet.

## Frequently Asked Questions

#### Why did you choose to implement this in pure Lua instead of using the `Prometheus` JS library?

Great question! There are a few key reasons behind my decision to implement the Prometheus types in pure Lua:

- Recently, an artifact build caused scripts using `Node.js` to crash the FX server upon restart, leading to my concerns about the current stability of `Node.js` in this environment.
- `Node.js` has slower execution times when interacting with FiveM natives, which could impact performance.
- Since the codebase is relatively small, maintaining manual type safety wasn't a significant concern.

#### How do I use this?

While this project is still a work in progress and not recommended for production use just yet, if you're feeling adventurous and want to try it out, here's how to get started.

1) Download or clone the repository into your FiveM resources folder.
2) Place the `prometheus.cfg` file in your FiveM server's root directory and reference it in your `server.cfg` by adding `exec prometheus.cfg`.
3) Configure any authentication settings in the `prometheus.cfg` file as needed.
4) Add a new Prometheus scrape job using the endpoint `<server_ip>:30120/fx_prometheus`.

The data is now ready to be visualised via `Grafana`.

## License

[Attribution-NonCommercial-ShareAlike 4.0 International]([https://choosealicense.com/licenses/mit/](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en))