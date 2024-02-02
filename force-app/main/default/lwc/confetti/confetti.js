import { LightningElement } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CONFETTI from "@salesforce/resourceUrl/confetti";

export default class Confetti extends LightningElement {
    myconfetti;


  connectedCallback() {
    Promise.all([
      loadScript(this, CONFETTI )
    ])
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Dependencies loaded successfully",
            variant: "Success"
          })
        );
        this.setUpCanvas();
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.message,
            variant: error,
            mode:"Sticky"
          })
        );
      });
  }


  setUpCanvas() {
    var confettiCanvas = this.template.querySelector("canvas.confettiCanvas");
    this.myconfetti = confetti.create(confettiCanvas, { resize: true });
    this.myconfetti({
      zIndex: 10000
    });
  }

  basicCannon() {
    confetti({
      particleCount: 100,
      spread: 70,
      origin: {
        y: 0.6
      }
    });
  }


  randomFun(min, max) {
    return Math.random() * (max - min) + min;
  }


  randomCannon() {
    confetti({
      angle: this.randomFun(55, 125),
      spread: this.randomFun(50, 70),
      particleCount: this.randomFun(50, 100),
      origin: {
        y: 0.6
      }
    });
  }


  fireworks() {
    var end = Date.now() + 15 * 1000;


    // eslint-disable-next-line @lwc/lwc/no-async-operation
    let interval = setInterval(function() {
      if (Date.now() > end) {
        return clearInterval(interval);
      }


      // eslint-disable-next-line no-undef
      confetti({
        startVelocity: 30,
        spread: 360,
        ticks: 60,
        origin: {
          x: Math.random(),
          // since they fall down, start a bit higher than random
          y: Math.random() - 0.2
        }
      });
    }, 200);
  }
}