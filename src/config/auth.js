
import { Strategy as LocalStrategy } from "passport-local";
import bcrypt from "bcrypt";
import supabase from "../config/supabase.js";

export default function (passport) {
    passport.use(
        new LocalStrategy(
            {
                usernameField: "email",
                passwordField: "senha"
            },
            async (email, senha, done) => {
                try {
                    const { data: user, error } = await supabase
                        .from("usuario")
                        .select("*")
                        .eq("email", email)
                        .maybeSingle();

                    if (error) {
                        console.error(
                            "Erro ao consultar usuário no Supabase:",
                            error
                        );

                        return done(error);
                    }

                    if (!user) {
                        return done(null, false, {
                            message: "Usuário não encontrado"
                        });
                    }

                    const senhaValida = await bcrypt.compare(
                        senha,
                        user.senha
                    );

                    if (!senhaValida) {
                        return done(null, false, {
                            message: "Senha inválida"
                        });
                    }

                    return done(null, user);
                } catch (err) {
                    return done(err);
                }
            }
        )
    );

    passport.serializeUser((user, done) => {
        done(null, user.id);
    });

    passport.deserializeUser(async (id, done) => {
        try {
            const { data: user, error } = await supabase
                .from("usuario")
                .select("*")
                .eq("id", id)
                .maybeSingle();

            if (error) {
                return done(error);
            }

            done(null, user);
        } catch (err) {
            done(err);
        }
    });
}
