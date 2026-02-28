---
title: "Hotwire Outside of Rails"
date: 2024-08-03
description: "Discover how to implement Hotwire's Turbo Streams and Stimulus in a BunJS application, proving that reactive web development isn't exclusive to Rails. Learn to build real-time chat functionality using WebSockets, Turbo Streams for DOM updates, and Stimulus controllers for interactive behavior. A practical guide that demonstrates the versatility of Hotwire technologies beyond the Ruby ecosystem."
tags: ["bunjs", "hotwire", "websockets"]
---

![Hotwire Turbo Streams demo running outside of Rails](/assets/blog/hotwire-demo.webp)
_A live Turbo Streams chat demo built with BunJS_

This blog article is inspired by a [Hotwire Turbo streams tutorial for Sinatra](https://www.writesoftwarewell.com/understanding-hotwire-turbo-streams/ "https://www.writesoftwarewell.com/understanding-hotwire-turbo-streams/").

When you search for Hotwire tutorials on Google, you'll find that most of the results are related to Ruby on Rails. Even the Hotwire guides predominantly use Ruby on Rails as an example for implementing Turbo Streams.

This does not really come as a surprise, as the framework has been created by the same company behind the Ruby on Rails framework.

However, it's important to recognize that Hotwire is not exclusively a Rails framework. In this blog article, I aim to convince you that Hotwire can be used beyond the Rails context, especially Turbo, its core feature.

## Goals

In this blog article, I will explain:

1. Setting up a BunJS Application
2. Implementing client and server-side Web Sockets
3. Using turbo streams to update the UI
4. Creating a stimulus controller attached to the DOM

## Step 1: Set up a BunJS Application

Initially, I considered using Java Spring for this blog, but I encountered challenges with Web Sockets. Instead, I opted for a much simpler TypeScript application.

Let's start by initializing a new BunJS application:

```bash
mkdir bunjs-turbo-demo
cd bunjs-turbo-demo
bun init
```

Now, let's run the application:

```bash
bun run index.ts
Hello via Bun!
```

## Step 2: Implement a Simple Web Socket / HTTP Server with BunJS

Web Sockets serve as the backbone for real-time communication in our project. In this step, we'll create a basic Web socket HTTP server using Bun. Web Sockets are essential for enabling bidirectional communication between clients (such as web browsers) and the server.

### The Multiple Publisher - Multiple Subscriber Pattern

Our approach involves implementing the **multiple publisher - multiple subscriber pattern**. Here's how it works:

1. **Client Interaction**:
   - Clients (users' web browsers) initiate actions, such as sending chat messages or requesting updates.
   - These interactions trigger Web Socket connections to the server.
2. **Server Processing**:
   - The server receives messages from multiple clients.
   - It processes these messages and prepares appropriate responses.
3. **Broadcasting Updates**:
   - When a client sends a message (e.g., a new chat message), the server broadcasts it to all connected clients.
   - This ensures that everyone receives the latest updates in real time.
4. **Seamless Communication**:
   - Web Sockets allow seamless, low-latency communication.
   - Clients can instantly receive updates without the need for manual page refreshes.

Here is a simple sequence diagram showing the core idea of this project:

![Sequence diagram of the client-server interactions](/assets/blog/hotwire-sequence-diagram.webp)
_Multiple publisher / multiple subscriber pattern over WebSockets_

### Implement the server

For brevity, I've omitted the code for view helpers such as `layoutHTML` and `chatRoomHTML`. These helpers handle rendering HTML components and chat room layouts. While important, their details won't significantly impact the core concepts discussed in this blog.

```ts
const topic = "chatroom";

Bun.serve({
  port: 8080,
  fetch(req, server) {
    const url = new URL(req.url);

    if (url.pathname === "/")
      return new Response(layoutHTML("Chatroom", chatRoomHTML()), {
        headers: {
          "Content-Type": "text/html",
        },
      });

    if (url.pathname === "/subscribe") {
      if (server.upgrade(req)) {
        return;
      }
      return new Response("Couldn't upgrade to a WebSocket connection");
    }

    return new Response("404!");
  },
  websocket: {
    open(ws) {
      console.log("Websocket opened");
      ws.subscribe(topic);
      ws.publishText(topic, messageHTML("Someone joined the chat"));
    },
    message(ws, message) {
      console.log("Websocket received: ", message);
      ws.publishText(topic, messageHTML(`Anonymous: ${message}`));
    },
    close(ws) {
      console.log("Websocket closed");
      ws.publishText(topic, messageHTML("Someone left the chat"));
    },
    publishToSelf: true,
  },
});
```

#### Implement the client

The application is incomplete without the client, which connects to the Web Socket server. Following the Web Socket server connection documentation, connecting to the backend is straightforward:

```ts
const client = new WebSocket("ws://localhost:8080/subscribe");
const form = document.getElementById("chat-form");
const chatFeed = document.getElementById("chat-feed");

client.addEventListener("message", (event) => {
  chatFeed.innerHTML += event.data;
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const formData = new FormData(form);
  const message = formData.get("message");
  client.send(message);
  form.reset();
});
```

Don't forget to add the route for the JavaScript file to the backend and include it inside your view using a module script tag. Also, make sure to implement the backend response.

##### The problem

As you can see here, every change in UI needs to be manually implemented. At the moment, we are listening to a single event and updating one single element. When the application grows in complexity, the JavaScript code grows, too. What if I told you that we can "almost" completely eliminate the client code by introducing Turbo streams?

### Step 3: Implement Turbo streams

[Turbo](https://turbo.hotwired.dev/ "https://turbo.hotwired.dev/") is a vital part of the Hotwire Framework. It enables you to dramatically reduce the amount of custom JavaScript you need to write.

The most relevant feature for this application are the turbo streams. They enable us to deliver page changes in the form of HTML over the wire.

Importing Turbo is as simple as including this snippet of code inside our layout file:

```html
<script type="module">
  import hotwiredTurbo from "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.3/+esm";
</script>
```

In order to use Web Sockets for Turbo streams in the frontend, we can use the following snippet from the [stream documentation](https://turbo.hotwired.dev/handbook/streams "https://turbo.hotwired.dev/handbook/streams"):

```html
<turbo-stream-source src="ws://localhost:8080/subscribe" />
```

In order to update the UI when a message is sent, we broadcast the following HTML through Web Sockets:

```html
<turbo-stream action="append" target="chat-feed">
  <template>
    <p class="notice">Anonymous: Hello World!</p>
  </template>
</turbo-stream>
```

This method of HTML updates stands out for its transparency and simplicity. Firstly, we select an element with the `#chat-feed` selector and then `append` to it the contents of the broadcasted template. In this case, a paragraph containing the user message. This also eliminates _almost_ all the client-side JavaScript needed for page update.

#### Step 4: Implement Form Controller

Before introducing turbo, we added a simple event listener to reset the Form after the data has been sent to the server. We now need to bring the functionality back, but without reusing the old code. We could use a turbo-stream to reset the form or even a turbo-frame, but rather than using that, I decided to use another library of the Hotwire framework, namely Stimulus:

> Stimulus is a JavaScript framework with modest ambitions. It doesn't seek to take over your entire front-end—in fact, it's not concerned with rendering HTML at all. Instead, it's designed to augment your HTML with just enough behavior to make it shine.
>
> [https://stimulus.hotwired.dev/](https://stimulus.hotwired.dev/ "https://stimulus.hotwired.dev/")

This is a simple code snippet for the Form Stimulus controller:

```ts
import {
  Application,
  Controller,
} from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/+esm";

class FormController extends Controller {
  clear() {
    this.element.reset();
  }
}

const application = Application.start();
application.register("form", FormController);
```

This is what the form HTML looks like, with data attributes used to attach the controller to the DOM and hook the events up to the corresponding controller methods:

```html
<form
  id="chat-form"
  action="/submit"
  method="post"
  data-controller="form"
  data-action="turbo:submit-end->form#clear"
>
  <label for="message-input">Message:</label>
  <input name="message" data-form-target="input" required />
  <input type="hidden" name="clientId" value="${clientId}" />
  <input type="submit" value="Send" />
</form>
```

The event that works best for form submission in that case is [turbo:submit-end](https://turbo.hotwired.dev/reference/events). Following the documentation of [Stimulus descriptors,](https://stimulus.hotwired.dev/reference/actions#descriptors "https://stimulus.hotwired.dev/reference/actions#descriptors") we can call the `#clear()` method after the form submission event. We are not using the `submit` event because this would clear the form prematurely.

#### Conclusion

- Hotwire is a JavaScript framework that helps us make applications more interactive while keeping the JavaScript code to a minimum. While the framework has been created by the authors of Ruby on Rails, the framework itself is backend agnostic.
- Turbo streams enable us to update client user interfaces asynchronously without the need for any (in some cases, just very little) frontend code.
- Stimulus enables us to add simple JavaScript behavior to our HTML with the use of Stimulus Controllers and data-attributes.

#### Where can I find the source?

You can find the complete chatting application with additional features such as:

- Client identification via Query Parameters
- Random username generation
- Real-time user list

The GitHub Repository for this project can be found here: [https://github.com/cb341/bunjs-turbo-demo](https://github.com/cb341/bunjs-turbo-demo "https://github.com/cb341/bunjs-turbo-demo")
