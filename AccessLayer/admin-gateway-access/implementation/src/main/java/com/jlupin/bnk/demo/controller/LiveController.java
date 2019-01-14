package com.jlupin.bnk.demo.controller;

import com.jlupin.impl.client.util.channel.JLupinClientChannelIterableProducer;
import com.jlupin.bnk.demo.service.interfaces.StatsCollectorService;
import com.jlupin.bnk.demo.service.pojo.EventView;
import org.reactivestreams.Publisher;
import org.reactivestreams.Subscriber;
import org.reactivestreams.Subscription;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import javax.servlet.http.HttpServletResponse;
import java.util.Iterator;

@RestController
@CrossOrigin(origins = "*")
class LiveController {

	private final StatsCollectorService statsCollectorService;
	private final JLupinClientChannelIterableProducer jLupinClientChannelIterableProducer;


	@Autowired
	LiveController(
			@Qualifier("statsCollectorService") StatsCollectorService statsCollectorService,
			JLupinClientChannelIterableProducer jLupinClientChannelIterableProducer) {
		this.statsCollectorService = statsCollectorService;
		this.jLupinClientChannelIterableProducer = jLupinClientChannelIterableProducer;
	}

	@GetMapping("/list")
	public Flux<EventView> list(HttpServletResponse response) throws Throwable {
		response.setHeader("Access-Control-Allow-Origin", "*");
		final String streamId = statsCollectorService.makeChannelStreamReadable();
		final Iterable iterable = jLupinClientChannelIterableProducer.produceChannelIterable("ADM", streamId);
		return Flux.from(new Publisher<EventView>() {
			@Override
			public void subscribe(final Subscriber<? super EventView> subscriber) {
				subscriber.onSubscribe(new MySubscription(subscriber, iterable.iterator()));
			}

			class MySubscription implements Subscription {
				private final Subscriber<? super EventView> subscriber;
				private final Iterator<EventView> iterator;
				private boolean canceled;

				public MySubscription(final Subscriber<? super EventView> subscriber, final Iterator<EventView> iterator) {
					this.subscriber = subscriber;
					this.iterator = iterator;
					this.canceled = false;
				}

				@Override
				public void request(final long l) {
 					for (long i = 0; i < l && !canceled; ++i) {
						if (iterator.hasNext()) {
							final EventView res = iterator.next();
							subscriber.onNext(res);
						} else {
							subscriber.onComplete();
							statsCollectorService.closeChannel(streamId);
							break;
						}
					}
				}

				@Override
				public void cancel() {
					this.canceled = true;
				}
			}
		});
	}


}
