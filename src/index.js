import { Container } from "@cloudflare/containers";

export class JoynFrontend extends Container {
  defaultPort = 80;
  sleepAfter = "10m";
}

export default {
  async fetch(request, env) {
    const container = env.JOYN_FRONTEND.getByName("frontend");
    return container.fetch(request);
  },
};
