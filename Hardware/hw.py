from yolobit import *
button_a.on_pressed = None
button_b.on_pressed = None
button_a.on_pressed_ab = button_b.on_pressed_ab = -1
from mqtt import *
import dht
from event_manager import *
import music
import time
from aiot_rgbled import RGBLed

event_manager.reset()

def sound_alarm():
  for count in range(5):
    music.play(['A5:1'], wait=True)
    music.play(['E5:1'], wait=True)

def on_mqtt_message_receive_callback__door_(door):
  global dht, led, led3, led1, led2, led4, fan
  display.scroll(door)
  if door == '1':
    pin6.servo_write(180)
    time.sleep_ms(1000)
    pin6.servo_release()
  if door == '0':
    pin6.servo_write(0)
    time.sleep_ms(1000)
    pin6.servo_release()

tiny_rgb = RGBLed(pin1.pin, 4)

def on_mqtt_message_receive_callback__led_(led):
  global dht, door, led3, led1, led2, led4, fan
  tiny_rgb.show(0, hex_to_rgb(led))

def on_mqtt_message_receive_callback__led3_(led3):
  global dht, door, led, led1, led2, led4, fan
  tiny_rgb.show(3, hex_to_rgb(led3))

def on_mqtt_message_receive_callback__led1_(led1):
  global dht, door, led, led3, led2, led4, fan
  tiny_rgb.show(1, hex_to_rgb(led1))

def on_mqtt_message_receive_callback__led2_(led2):
  global dht, door, led, led3, led1, led4, fan
  tiny_rgb.show(2, hex_to_rgb(led2))

def on_mqtt_message_receive_callback__led4_(led4):
  global dht, door, led, led3, led1, led2, fan
  tiny_rgb.show(4, hex_to_rgb(led4))

def on_mqtt_message_receive_callback__fan_(fan):
  global dht, door, led, led3, led1, led2, led4
  pin3.write_analog(round(translate(int(fan), 0, 100, 0, 1023)))

def on_event_timer_callback_S_q_b_i_y():
  global dht, door, led, led3, led1, led2, led4, fan
  _h_Wl4_R1K2J_S_600o_vn.measure()
  mqtt.publish('temp', (_h_Wl4_R1K2J_S_600o_vn.temperature()))
  mqtt.publish('hum', (_h_Wl4_R1K2J_S_600o_vn.humidity()))

event_manager.add_timer_event(10000, on_event_timer_callback_S_q_b_i_y)

if True:
  display.scroll('X')
  mqtt.connect_wifi('QUANGKIET', '02838331443')
  mqtt.connect_broker(server='io.adafruit.com', port=1883, username='Kietlun9302', password='aio_nWgL63JKpMGPYqz5CZTATiOvzWpq')
  _h_Wl4_R1K2J_S_600o_vn = dht.DHT11(Pin(pin2.pin))
  display.scroll('o')

while True:
  mqtt.check_message()
  event_manager.run()
  if pin4.read_digital()==0:
    sound_alarm()
  mqtt.on_receive_message('door', on_mqtt_message_receive_callback__door_)
  mqtt.on_receive_message('led', on_mqtt_message_receive_callback__led_)
  mqtt.on_receive_message('led3', on_mqtt_message_receive_callback__led3_)
  mqtt.on_receive_message('led1', on_mqtt_message_receive_callback__led1_)
  mqtt.on_receive_message('led2', on_mqtt_message_receive_callback__led2_)
  mqtt.on_receive_message('led4', on_mqtt_message_receive_callback__led4_)
  mqtt.on_receive_message('fan', on_mqtt_message_receive_callback__fan_)
  time.sleep_ms(1000)


dht
