package br.com.hematsu.lance_certo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class LanceCertoApplication {

 	public static void main(String[] args) {
		SpringApplication.run(LanceCertoApplication.class, args);
	}

}
