package com.bcp.training.serde;

import com.bcp.training.event.SpeakerWasCreated;
import io.quarkus.kafka.client.serialization.ObjectMapperDeserializer;

public class SpeakerWasCreatedDeserializer
        extends ObjectMapperDeserializer<SpeakerWasCreated> {
    public  SpeakerWasCreatedDeserializer() {
        super(SpeakerWasCreated.class);
    }
}
