package com.sangam.sangamdairybackend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

@Configuration
public class  MailConfig {

    private static final Logger log = LoggerFactory.getLogger(MailConfig.class);

    @Value("${spring.mail.host:smtp.gmail.com}")
    private String host;

    @Value("${spring.mail.port:587}")
    private int port;

    @Value("${spring.mail.username:gandragopigandra123@gmail.com}")
    private String defaultUsername;

    @Value("${spring.mail.password:vvnfbbauwhjrpfhv}")
    private String defaultPassword;

    @Bean
    public JavaMailSender javaMailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(host);
        mailSender.setPort(port);

        String username = System.getenv("SPRING_MAIL_USERNAME");
        if (username == null || username.isBlank()) {
            username = System.getenv("SMTP_USERNAME");
        }
        if (username == null || username.isBlank()) {
            username = defaultUsername;
        }
        mailSender.setUsername(username);

        String password = System.getenv("SPRING_MAIL_PASSWORD");
        if (password == null || password.isBlank()) {
            password = System.getenv("SMTP_APP_PASSWORD");
        }
        if (password == null || password.isBlank()) {
            password = defaultPassword;
        }

        if (password != null && !password.isBlank()) {
            String cleanedPassword = password.replaceAll("\\s+", "");
            mailSender.setPassword(cleanedPassword);
            log.info(" [MAIL CONFIG] SMTP Username loaded: {}, Password length: {}", username, cleanedPassword.length());
        } else {
            mailSender.setPassword("vvnfbbauwhjrpfhv");
            log.info(" [MAIL CONFIG] Using fallback SMTP App Password.");
        }

        Properties props = mailSender.getJavaMailProperties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", "*");
        props.put("mail.debug", "true");
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");
        props.put("mail.smtp.writetimeout", "5000");

        return mailSender;
    }
}
